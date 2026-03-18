import Foundation
import os
import SpotifyiOS
import UIKit

final class SpotifyService: NSObject {

    // MARK: - Configuration (loaded from Secrets.xcconfig → Info.plist)
    static let clientID: String = Bundle.main.object(forInfoDictionaryKey: "SPOTIFY_CLIENT_ID") as? String ?? ""
    static let redirectURI = URL(string: "moments-spotify-auth://callback")!

    // MARK: - Callbacks (set by MusicViewModel)
    var onConnected: (() -> Void)?
    var onDisconnected: ((Error?) -> Void)?
    var onPlayerStateChanged: ((SpotifyPlayerState) -> Void)?
    var onAuthorizationFailed: ((String) -> Void)?

    // MARK: - Properties
    private static let keychainTokenKey = "spotify_access_token"
    private(set) var accessToken: String?
    private(set) var isConnected = false

    /// Action to execute once the App Remote re-establishes a connection.
    private var pendingPlaybackAction: (() -> Void)?

    /// Whether we have already attempted a session renewal for this connection cycle,
    /// to avoid an infinite renewal loop.
    private var hasAttemptedRenewal = false

    /// Consecutive silent reconnect attempts since last successful connection.
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 3

    private lazy var configuration: SPTConfiguration = {
        let config = SPTConfiguration(clientID: Self.clientID, redirectURL: Self.redirectURI)
        config.playURI = ""
        return config
    }()

    lazy var appRemote: SPTAppRemote = {
        let remote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        remote.delegate = self
        return remote
    }()

    private lazy var sessionManager = SPTSessionManager(configuration: configuration, delegate: self)

    // MARK: - Authorization

    func authorize() -> String? {
        #if targetEnvironment(simulator)
        return "Spotify App Remote skal testes på en fysisk iPhone eller iPad, ikke i simulatoren."
        #else
        guard !Self.clientID.isEmpty else {
            return "Spotify client ID is missing from the app configuration."
        }

        guard let spotifyURL = URL(string: "spotify://") else {
            return "Kunne ikke oprette Spotify URL."
        }

        guard UIApplication.shared.canOpenURL(spotifyURL) else {
            return "Spotify-appen er ikke installeret eller kan ikke åbnes på denne enhed."
        }

        let requestedScopes: SPTScope = [
            .appRemoteControl,
            .playlistReadPrivate,
            .playlistReadCollaborative
        ]
        sessionManager.initiateSession(with: requestedScopes, options: .default, campaign: nil)

        return nil
        #endif
    }

    /// Returns `nil` on success, or an error message on failure.
    func handleURL(_ url: URL) -> String? {
        _ = sessionManager.application(UIApplication.shared, open: url, options: [:])

        let parameters = appRemote.authorizationParameters(from: url)

        if let errorDesc = parameters?[SPTAppRemoteErrorDescriptionKey] {
            return "Spotify auth error: \(errorDesc)"
        }

        return nil
    }

    // MARK: - Token Persistence

    func restoreToken() {
        guard accessToken == nil,
              let stored = KeychainService.load(key: Self.keychainTokenKey) else { return }
        accessToken = stored
        appRemote.connectionParameters.accessToken = stored
    }

    // MARK: - Connection

    func connect() {
        restoreToken()
        guard let _ = accessToken else { return }
        guard !appRemote.isConnected else { return }
        hasAttemptedRenewal = false
        appRemote.connect()
    }

    func disconnect() {
        if appRemote.isConnected {
            appRemote.disconnect()
        }
    }

    func disconnectAndForgetSession() {
        disconnect()
        accessToken = nil
        appRemote.connectionParameters.accessToken = nil
        KeychainService.delete(key: Self.keychainTokenKey)
    }

    // MARK: - Playback Controls

    func play(uri: String) {
        performWhenConnected { [weak self] in
            self?.appRemote.playerAPI?.play(uri, callback: self?.defaultCallback)
        }
    }

    func pause() {
        performWhenConnected { [weak self] in
            self?.appRemote.playerAPI?.pause(self?.defaultCallback)
        }
    }

    func resume() {
        performWhenConnected { [weak self] in
            self?.appRemote.playerAPI?.resume(self?.defaultCallback)
        }
    }

    func skipNext() {
        performWhenConnected { [weak self] in
            self?.appRemote.playerAPI?.skip(toNext: self?.defaultCallback)
        }
    }

    func skipPrevious() {
        performWhenConnected { [weak self] in
            self?.appRemote.playerAPI?.skip(toPrevious: self?.defaultCallback)
        }
    }

    /// Runs `action` immediately if the App Remote is connected, otherwise
    /// stores it and triggers a reconnect so it fires once the connection is ready.
    private func performWhenConnected(_ action: @escaping () -> Void) {
        if appRemote.isConnected {
            action()
        } else {
            pendingPlaybackAction = action
            // appRemote.connect() only works if Spotify is already active in
            // the background. authorizeAndPlayURI("") brings Spotify to the
            // foreground and re-establishes the App Remote connection without
            // changing the currently playing track (empty URI = resume current).
            if accessToken != nil {
                appRemote.authorizeAndPlayURI("")
            } else {
                connect()
            }
        }
    }

    func getPlayerState() {
        appRemote.playerAPI?.getPlayerState { [weak self] result, error in
            guard let state = result as? SPTAppRemotePlayerState else { return }
            self?.publishPlayerState(state)
        }
    }

    // MARK: - Private Helpers

    private var defaultCallback: SPTAppRemoteCallback {
        { [weak self] _, error in
            if let error {
                Log.spotify.error("Playback error: \(error.localizedDescription, privacy: .private)")
            } else {
                // Re-fetch player state after every command so the UI stays in sync.
                self?.getPlayerState()
            }
        }
    }

    private func mapPlayerState(_ state: SPTAppRemotePlayerState, artworkURL: URL? = nil) -> SpotifyPlayerState {
        let track = state.track
        return SpotifyPlayerState(
            trackName: track.name,
            artistName: track.artist.name,
            albumName: track.album.name,
            artworkURL: artworkURL,
            isPaused: state.isPaused,
            durationMs: Int(track.duration),
            positionMs: Int(state.playbackPosition),
            trackURI: track.uri
        )
    }

    private func publishPlayerState(_ state: SPTAppRemotePlayerState) {
        let baseState = mapPlayerState(state)
        guard !state.track.imageIdentifier.isEmpty else {
            onPlayerStateChanged?(baseState)
            return
        }

        appRemote.imageAPI?.fetchImage(
            forItem: state.track,
            with: CGSize(width: 400, height: 400),
            callback: { [weak self] result, error in
                if let error {
                    Log.spotify.error("Artwork fetch error: \(error.localizedDescription, privacy: .private)")
                    self?.onPlayerStateChanged?(baseState)
                    return
                }

                guard let image = result as? UIImage, let data = image.pngData() else {
                    self?.onPlayerStateChanged?(baseState)
                    return
                }

                let temporaryURL = self?.writeArtworkImage(data, trackURI: state.track.uri)
                self?.onPlayerStateChanged?(self?.mapPlayerState(state, artworkURL: temporaryURL) ?? baseState)
            }
        )
    }

    private func writeArtworkImage(_ data: Data, trackURI: String) -> URL? {
        let sanitizedTrackID = trackURI.replacingOccurrences(of: ":", with: "_")
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("spotify_artwork_\(sanitizedTrackID)")
            .appendingPathExtension("png")

        do {
            try data.write(to: fileURL, options: .atomic)
            return fileURL
        } catch {
            Log.spotify.error("Artwork cache write error: \(error.localizedDescription, privacy: .private)")
            return nil
        }
    }

    private func formatSpotifyError(_ error: Error) -> String {
        let nsError = error as NSError
        let codeDescription: String

        switch nsError.code {
        case 0:
            codeDescription = "Unknown Spotify error"
        case 1:
            codeDescription = "Spotify authorization failed"
        case 2:
            codeDescription = "Spotify session renewal failed"
        case 3:
            codeDescription = "Spotify returned invalid JSON"
        default:
            codeDescription = "Spotify error"
        }

        let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? NSError
        let underlyingDescription = underlyingError?.localizedDescription ?? nsError.localizedDescription
        return "\(codeDescription) (domain: \(nsError.domain), code: \(nsError.code)): \(underlyingDescription)"
    }

}

// MARK: - SPTAppRemoteDelegate

extension SpotifyService: SPTAppRemoteDelegate {
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        isConnected = true
        reconnectAttempts = 0
        hasAttemptedRenewal = false

        appRemote.playerAPI?.delegate = self
        appRemote.playerAPI?.subscribe(toPlayerState: { [weak self] _, error in
            if let error {
                Log.spotify.error("Subscribe error: \(error.localizedDescription, privacy: .private)")
            } else {
                // Fetch current state immediately after subscribing so the UI
                // reflects what is actually playing, including after a reconnect.
                self?.getPlayerState()
            }
        })

        // Flush any queued playback command that was waiting for reconnection.
        if let action = pendingPlaybackAction {
            pendingPlaybackAction = nil
            action()
        }

        onConnected?()
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        isConnected = false
        pendingPlaybackAction = nil

        // Code -2001 is "End of stream" — Spotify's TCP connection timed out
        // because the Spotify app went to background. Silently reconnect.
        // Any other code (e.g. -2000 "Stream error") means Spotify is not
        // reachable and we surface the disconnect to the ViewModel immediately.
        let isEndOfStream = (error as NSError?)?.code == -2001
        if isEndOfStream, accessToken != nil, reconnectAttempts < maxReconnectAttempts {
            reconnectAttempts += 1
            Log.spotify.debug("End of stream — scheduling silent reconnect (attempt \(self.reconnectAttempts)/\(self.maxReconnectAttempts))")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                guard let self, !self.appRemote.isConnected else { return }
                self.appRemote.connect()
            }
        } else {
            reconnectAttempts = 0
            onDisconnected?(error)
        }
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        isConnected = false

        // If the token may have expired, attempt a silent renewal once before
        // surfacing the failure to the caller. The sessionManager will call
        // didRenew (which reconnects) or didFailWith (which surfaces the error).
        if !hasAttemptedRenewal, accessToken != nil {
            hasAttemptedRenewal = true
            sessionManager.renewSession()
            return
        }

        pendingPlaybackAction = nil
        onDisconnected?(error)
    }
}

// MARK: - SPTSessionManagerDelegate

extension SpotifyService: SPTSessionManagerDelegate {
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        Log.spotify.debug("Session initiated")
        accessToken = session.accessToken
        appRemote.connectionParameters.accessToken = session.accessToken
        KeychainService.save(key: Self.keychainTokenKey, data: session.accessToken)
        connect()
    }

    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        let message = formatSpotifyError(error)
        Log.spotify.error("Session initiation failed: \(message, privacy: .private)")
        onAuthorizationFailed?(message)
    }

    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        Log.spotify.debug("Session renewed")
        accessToken = session.accessToken
        appRemote.connectionParameters.accessToken = session.accessToken
        KeychainService.save(key: Self.keychainTokenKey, data: session.accessToken)
        // Reconnect with the fresh token so any pending playback action can fire.
        appRemote.connect()
    }
}

// MARK: - SPTAppRemotePlayerStateDelegate

extension SpotifyService: SPTAppRemotePlayerStateDelegate {
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        publishPlayerState(playerState)
    }
}


