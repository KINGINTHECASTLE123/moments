import Foundation
import os
import SpotifyiOS
import UIKit

@MainActor
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

    /// URI to pass to Spotify if we need to foreground the app to recover playback.
    private var pendingLaunchURI: String?

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
        return Strings.spotifySimulatorError
        #else
        guard !Self.clientID.isEmpty else {
            return Strings.spotifyClientIDMissing
        }

        guard let spotifyURL = URL(string: "spotify://") else {
            return Strings.spotifyURLError
        }

        guard UIApplication.shared.canOpenURL(spotifyURL) else {
            return Strings.spotifyNotInstalled
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
            return Strings.spotifyAuthError(errorDesc)
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
        queuePlaybackCommand(launchURI: uri) { [weak self] in
            self?.appRemote.playerAPI?.play(uri, callback: self?.defaultCallback)
        }
    }

    func pause() {
        queuePlaybackCommand { [weak self] in
            self?.appRemote.playerAPI?.pause(self?.defaultCallback)
        }
    }

    func resume() {
        queuePlaybackCommand { [weak self] in
            self?.appRemote.playerAPI?.resume(self?.defaultCallback)
        }
    }

    func skipNext() {
        queuePlaybackCommand { [weak self] in
            self?.appRemote.playerAPI?.skip(toNext: self?.defaultCallback)
        }
    }

    func skipPrevious() {
        queuePlaybackCommand { [weak self] in
            self?.appRemote.playerAPI?.skip(toPrevious: self?.defaultCallback)
        }
    }

    private func queuePlaybackCommand(launchURI: String = "", action: @escaping () -> Void) {
        pendingLaunchURI = launchURI
        pendingPlaybackAction = action
        performWhenConnected(action)
    }

    /// Runs `action` immediately if the App Remote is connected, otherwise
    /// stores it and triggers a reconnect so it fires once the connection is ready.
    private func performWhenConnected(_ action: @escaping () -> Void) {
        if appRemote.isConnected, appRemote.playerAPI != nil {
            action()
        } else {
            pendingPlaybackAction = action
            // Try silent reconnect first. Only escalate to authorizeAndPlayURI
            // if connect() fails (handled in didFailConnectionAttemptWithError).
            if accessToken != nil {
                appRemote.connect()
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
                self?.recoverPlaybackCommand(after: error)
            } else {
                self?.pendingPlaybackAction = nil
                self?.pendingLaunchURI = nil
                // Re-fetch player state after every command so the UI stays in sync.
                self?.getPlayerState()
            }
        }
    }

    private func recoverPlaybackCommand(after error: Error) {
        guard accessToken != nil, pendingPlaybackAction != nil else { return }

        let errorCode = (error as NSError).code
        if errorCode == -2000 || errorCode == -2001 {
            if appRemote.isConnected {
                appRemote.disconnect()
            }
            appRemote.connect()
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
    nonisolated func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        Task { @MainActor [weak self] in
            guard let self else { return }
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

            pendingLaunchURI = nil

            onConnected?()
        }
    }

    nonisolated func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            isConnected = false
            pendingPlaybackAction = nil
            pendingLaunchURI = nil

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
    }

    nonisolated func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            isConnected = false

            // Code -2000 (connection refused / stream error) means Spotify is not
            // running in the background. If there is a pending playback action,
            // escalate to authorizeAndPlayURI using the requested playback target.
            let isConnectionRefused = (error as NSError?)?.code == -2000
            if isConnectionRefused, accessToken != nil, pendingPlaybackAction != nil {
                Log.spotify.debug("Silent reconnect failed — escalating to authorizeAndPlayURI")
                let launchURI = self.pendingLaunchURI ?? ""
                _ = await self.appRemote.authorizeAndPlayURI(launchURI)
                return
            }

            if !isConnectionRefused, !hasAttemptedRenewal, accessToken != nil {
                hasAttemptedRenewal = true
                sessionManager.renewSession()
                return
            }

            pendingPlaybackAction = nil
            onDisconnected?(error)
        }
    }
}

// MARK: - SPTSessionManagerDelegate

extension SpotifyService: SPTSessionManagerDelegate {
    nonisolated func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        let token = session.accessToken
        Task { @MainActor [weak self] in
            guard let self else { return }
            Log.spotify.debug("Session initiated")
            accessToken = token
            appRemote.connectionParameters.accessToken = token
            KeychainService.save(key: Self.keychainTokenKey, data: token)
            connect()
        }
    }

    nonisolated func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            let message = formatSpotifyError(error)
            Log.spotify.error("Session initiation failed: \(message, privacy: .private)")
            // Clear the stale token so the next connect() doesn't loop on invalid_grant.
            accessToken = nil
            appRemote.connectionParameters.accessToken = nil
            KeychainService.delete(key: Self.keychainTokenKey)
            onAuthorizationFailed?(message)
        }
    }

    nonisolated func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        let token = session.accessToken
        Task { @MainActor [weak self] in
            guard let self else { return }
            Log.spotify.debug("Session renewed")
            accessToken = token
            appRemote.connectionParameters.accessToken = token
            KeychainService.save(key: Self.keychainTokenKey, data: token)
            // Reconnect with the fresh token so any pending playback action can fire.
            appRemote.connect()
        }
    }
}

// MARK: - SPTAppRemotePlayerStateDelegate

extension SpotifyService: SPTAppRemotePlayerStateDelegate {
    nonisolated func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        Task { @MainActor [weak self] in
            self?.publishPlayerState(playerState)
        }
    }
}
