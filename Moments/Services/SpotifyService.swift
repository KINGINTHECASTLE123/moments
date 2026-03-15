import Foundation
import SpotifyiOS
import UIKit

final class SpotifyService: NSObject {

    // MARK: - Configuration (replace with your credentials)
    static let clientID = "24d62dd7beb644a5abc30a9e70e6e6e3"
    static let redirectURI = URL(string: "moments-spotify-auth://callback")!

    // MARK: - Callbacks (set by MusicViewModel)
    var onConnected: (() -> Void)?
    var onDisconnected: ((Error?) -> Void)?
    var onPlayerStateChanged: ((SpotifyPlayerState) -> Void)?
    var onAuthorizationFailed: ((String) -> Void)?

    // MARK: - Properties
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

    // MARK: - Connection

    func connect() {
        guard let _ = accessToken else { return }
        guard !appRemote.isConnected else { return }
        appRemote.connect()
    }

    func disconnect() {
        if appRemote.isConnected {
            appRemote.disconnect()
        }
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

    // MARK: - Web API

    func fetchUserPlaylists() async throws -> [SpotifyPlaylistItem] {
        guard let token = accessToken else { throw SpotifyError.notAuthorized }

        var request = URLRequest(url: URL(string: "https://api.spotify.com/v1/me/playlists?limit=50")!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SpotifyError.invalidResponse
        }
        guard httpResponse.statusCode == 200 else {
            throw SpotifyError.apiError(
                statusCode: httpResponse.statusCode,
                responseBody: String(data: data, encoding: .utf8)
            )
        }

        let decoded: SpotifyPlaylistsResponse
        do {
            decoded = try JSONDecoder().decode(SpotifyPlaylistsResponse.self, from: data)
        } catch {
            throw SpotifyError.decodingError(context: decodeErrorContext(error, data: data))
        }
        return decoded.items
    }

    func fetchPlaylistTracks(playlistID: String) async throws -> [SpotifyTrackItem] {
        guard let token = accessToken else { throw SpotifyError.notAuthorized }

        var allTracks: [SpotifyTrackItem] = []
        var nextURL: URL? = URL(string: "https://api.spotify.com/v1/playlists/\(playlistID)/items?limit=100")

        while let url = nextURL {
            var request = URLRequest(url: url)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw SpotifyError.invalidResponse
            }

            guard httpResponse.statusCode == 200 else {
                throw SpotifyError.apiError(
                    statusCode: httpResponse.statusCode,
                    responseBody: String(data: data, encoding: .utf8)
                )
            }

            let decoded: SpotifyPlaylistTracksResponse
            do {
                decoded = try JSONDecoder().decode(SpotifyPlaylistTracksResponse.self, from: data)
            } catch {
                print("Spotify playlist tracks JSON decode error: \(decodeErrorContext(error, data: data))")
                // Fall back to manual parsing for this page
                let fallbackTracks = try parsePlaylistTracksFallback(from: data)
                allTracks.append(contentsOf: fallbackTracks)
                break
            }

            allTracks.append(contentsOf: decoded.items.compactMap(\.track))
            nextURL = decoded.next.flatMap { URL(string: $0) }
        }

        return allTracks
    }

    // MARK: - Private Helpers

    private var defaultCallback: SPTAppRemoteCallback {
        { _, error in
            if let error { print("Spotify playback error: \(error)") }
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
                    print("Spotify artwork fetch error: \(error)")
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
            print("Spotify artwork cache write error: \(error)")
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

    private func decodeErrorContext(_ error: Error, data: Data) -> String {
        let responseSnippet = String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .prefix(240) ?? "<non-utf8 response>"

        switch error {
        case let DecodingError.keyNotFound(key, context):
            return "Missing key '\(key.stringValue)' at \(codingPathDescription(context.codingPath)). Response: \(responseSnippet)"
        case let DecodingError.valueNotFound(_, context):
            return "Missing value at \(codingPathDescription(context.codingPath)). Response: \(responseSnippet)"
        case let DecodingError.typeMismatch(_, context):
            return "Type mismatch at \(codingPathDescription(context.codingPath)). Response: \(responseSnippet)"
        case let DecodingError.dataCorrupted(context):
            return "Data corrupted at \(codingPathDescription(context.codingPath)): \(context.debugDescription). Response: \(responseSnippet)"
        default:
            return "Decode failed: \(error.localizedDescription). Response: \(responseSnippet)"
        }
    }

    private func codingPathDescription(_ codingPath: [CodingKey]) -> String {
        if codingPath.isEmpty {
            return "<root>"
        }

        return codingPath.map(\.stringValue).joined(separator: ".")
    }

    private func parsePlaylistTracksFallback(from data: Data) throws -> [SpotifyTrackItem] {
        guard
            let rootObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let itemObjects = rootObject["items"] as? [[String: Any]]
        else {
            return []
        }

        return itemObjects.compactMap(parsePlaylistTrackItem)
    }

    private func parsePlaylistTrackItem(_ item: [String: Any]) -> SpotifyTrackItem? {
        // The /items endpoint (Feb 2026+) uses "item", older /tracks uses "track"
        guard let track = (item["item"] as? [String: Any]) ?? (item["track"] as? [String: Any]) else {
            return nil
        }

        guard
            let uri = track["uri"] as? String,
            let name = track["name"] as? String,
            let durationMs = track["duration_ms"] as? Int
        else {
            return nil
        }

        let artists: [SpotifyArtist] = (track["artists"] as? [[String: Any]] ?? []).compactMap { artistDict in
            guard let name = artistDict["name"] as? String else { return nil }
            return SpotifyArtist(id: artistDict["id"] as? String, name: name)
        }

        guard !artists.isEmpty else {
            return nil
        }

        let albumDict = track["album"] as? [String: Any] ?? [:]
        let albumImages: [SpotifyImage] = (albumDict["images"] as? [[String: Any]] ?? []).compactMap { imageDict in
            guard let url = imageDict["url"] as? String else { return nil }
            return SpotifyImage(
                url: url,
                width: imageDict["width"] as? Int,
                height: imageDict["height"] as? Int
            )
        }

        let album = SpotifyAlbum(
            id: albumDict["id"] as? String,
            name: albumDict["name"] as? String ?? "",
            images: albumImages
        )

        return SpotifyTrackItem(
            id: track["id"] as? String ?? uri,
            name: name,
            artists: artists,
            album: album,
            durationMs: durationMs,
            uri: uri
        )
    }
}

// MARK: - SPTAppRemoteDelegate

extension SpotifyService: SPTAppRemoteDelegate {
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        isConnected = true
        appRemote.playerAPI?.delegate = self
        appRemote.playerAPI?.subscribe(toPlayerState: { _, error in
            if let error { print("Spotify subscribe error: \(error)") }
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
        print("Spotify session initiated")
        accessToken = session.accessToken
        appRemote.connectionParameters.accessToken = session.accessToken
        connect()
    }

    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        let message = formatSpotifyError(error)
        print("Spotify session initiation failed: \(message)")
        onAuthorizationFailed?(message)
    }

    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        print("Spotify session renewed")
        accessToken = session.accessToken
        appRemote.connectionParameters.accessToken = session.accessToken
    }
}

// MARK: - SPTAppRemotePlayerStateDelegate

extension SpotifyService: SPTAppRemotePlayerStateDelegate {
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        publishPlayerState(playerState)
    }
}

// MARK: - Errors

enum SpotifyError: LocalizedError {
    case notAuthorized
    case invalidResponse
    case decodingError(context: String)
    case apiError(statusCode: Int, responseBody: String?)

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Not connected to Spotify"
        case .invalidResponse:
            return "Spotify returned an invalid response"
        case let .decodingError(context):
            return "Spotify decode error: \(context)"
        case let .apiError(statusCode, responseBody):
            let trimmedBody = responseBody?
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .prefix(160)

            if let trimmedBody, !trimmedBody.isEmpty {
                return "Spotify API error \(statusCode): \(trimmedBody)"
            }

            return "Spotify API error \(statusCode)"
        }
    }
}
