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
        appRemote.playerAPI?.play(uri, callback: defaultCallback)
    }

    func pause() {
        appRemote.playerAPI?.pause(defaultCallback)
    }

    func resume() {
        appRemote.playerAPI?.resume(defaultCallback)
    }

    func skipNext() {
        appRemote.playerAPI?.skip(toNext: defaultCallback)
    }

    func skipPrevious() {
        appRemote.playerAPI?.skip(toPrevious: defaultCallback)
    }

    func getPlayerState() {
        appRemote.playerAPI?.getPlayerState { [weak self] result, error in
            guard let state = result as? SPTAppRemotePlayerState else { return }
            self?.publishPlayerState(state)
        }
    }

    // MARK: - Private Helpers

    private var defaultCallback: SPTAppRemoteCallback {
        { _, error in
            if let error { Log.spotify.error("Playback error: \(error.localizedDescription, privacy: .private)") }
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

        appRemote.playerAPI?.delegate = self
        appRemote.playerAPI?.subscribe(toPlayerState: { _, error in
            if let error { Log.spotify.error("Subscribe error: \(error.localizedDescription, privacy: .private)") }
        })
        onConnected?()
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        isConnected = false
        onDisconnected?(error)
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        isConnected = false
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
    }
}

// MARK: - SPTAppRemotePlayerStateDelegate

extension SpotifyService: SPTAppRemotePlayerStateDelegate {
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        publishPlayerState(playerState)
    }
}


