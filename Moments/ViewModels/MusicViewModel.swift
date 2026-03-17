import Foundation
import os

@Observable @MainActor
final class MusicViewModel {
    private let spotifyService = SpotifyService()
    private var progressTimer: Timer?
    private var lastStateReceivedAt: Date?

    var isConnected = false
    var currentPlayerState: SpotifyPlayerState?
    var errorMessage: String?
    var playlistCovers: [String: String] = [:]  // playlistID -> coverImageURL

    init() {
        spotifyService.onConnected = { [weak self] in
            Task { @MainActor in
                self?.isConnected = true
                self?.spotifyService.getPlayerState()
            }
        }
        spotifyService.onDisconnected = { [weak self] _ in
            Task { @MainActor in
                self?.isConnected = false
                self?.stopProgressTimer()
            }
        }
        spotifyService.onPlayerStateChanged = { [weak self] state in
            Task { @MainActor in
                self?.currentPlayerState = state
                self?.lastStateReceivedAt = Date()
                if state.isPaused {
                    self?.stopProgressTimer()
                } else {
                    self?.startProgressTimer()
                }
            }
        }
        spotifyService.onAuthorizationFailed = { [weak self] message in
            Task { @MainActor in
                self?.errorMessage = message
            }
        }
    }

    // MARK: - Progress Timer

    private func startProgressTimer() {
        stopProgressTimer()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor [weak self] in
                self?.tickProgress()
            }
        }
    }

    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }

    private func tickProgress() {
        guard var state = currentPlayerState, !state.isPaused,
              let receivedAt = lastStateReceivedAt else { return }
        let elapsed = Int(Date().timeIntervalSince(receivedAt) * 1000)
        state.positionMs = min(state.positionMs + elapsed, state.durationMs)
        currentPlayerState = state
        lastStateReceivedAt = Date()
    }

    // MARK: - Authorization

    func authorize() {
        errorMessage = nil
        errorMessage = spotifyService.authorize()
    }

    func handleURL(_ url: URL) {
        // Only handle URLs from our Spotify redirect scheme
        guard url.scheme == "moments-spotify-auth" else { return }
        if let error = spotifyService.handleURL(url) {
            errorMessage = error
        }
    }

    // MARK: - Connection Lifecycle

    func connect() {
        spotifyService.connect()
    }

    func disconnect() {
        spotifyService.disconnect()
    }

    func disconnectAndForgetSession() {
        spotifyService.disconnectAndForgetSession()
        isConnected = false
        currentPlayerState = nil
        stopProgressTimer()
    }

    // MARK: - Playback Controls

    func play(uri: String) {
        spotifyService.play(uri: uri)
    }

    func pause() {
        spotifyService.pause()
    }

    func resume() {
        spotifyService.resume()
    }

    func togglePlayback() {
        guard let state = currentPlayerState else { return }
        if state.isPaused {
            resume()
        } else {
            pause()
        }
    }

    func skipNext() {
        spotifyService.skipNext()
    }

    func skipPrevious() {
        spotifyService.skipPrevious()
    }

    // MARK: - Cover Art Fetching

    func fetchPlaylistCovers() async {
        guard let token = spotifyService.accessToken else { return }

        for playlist in CuratedPlaylists.all {
            guard playlistCovers[playlist.id] == nil else { continue }

            let playlistID = playlist.id
            guard let url = URL(string: "https://api.spotify.com/v1/playlists/\(playlistID)?fields=images") else { continue }

            var request = URLRequest(url: url)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else { continue }

                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let images = json["images"] as? [[String: Any]],
                   let firstImage = images.first,
                   let imageURL = firstImage["url"] as? String {
                    playlistCovers[playlistID] = imageURL
                }
            } catch {
                continue
            }
        }
    }

    func coverURL(for playlistID: String) -> String? {
        playlistCovers[playlistID]
    }

    // MARK: - App Remote Access (for scene lifecycle)

    var appRemote: Any {
        spotifyService.appRemote
    }
}
