import Foundation
import os

@Observable @MainActor
final class MusicViewModel {
    private let spotifyService = SpotifyService()
    private var progressTimer: Timer?
    private var lastStateReceivedAt: Date?
    private var ignoreStateUpdatesUntil: Date?

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
                self?.currentPlayerState = nil
                self?.stopProgressTimer()
            }
        }
        spotifyService.onPlayerStateChanged = { [weak self] state in
            Task { @MainActor in
                // Suppress state updates that arrive within the debounce window
                // after an optimistic toggle, to prevent the button from reverting.
                if let until = self?.ignoreStateUpdatesUntil, Date() < until {
                    return
                }
                self?.currentPlayerState = state
                self?.lastStateReceivedAt = Date()
                if state.isPaused {
                    self?.stopProgressTimer()
                } else {
                    self?.startProgressTimer()
                }
            }
        }
        spotifyService.onAuthorizationFailed = { [weak self] _ in
            Task { @MainActor in
                // Token was invalid — clear state so the connect prompt shows cleanly.
                self?.isConnected = false
                self?.currentPlayerState = nil
                self?.stopProgressTimer()
            }
        }
    }

    // MARK: - Progress Timer

    private func startProgressTimer() {
        stopProgressTimer()
        let timer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor [weak self] in
                self?.tickProgress()
            }
        }
        // .common mode fires during scroll tracking, preventing progress drift
        RunLoop.main.add(timer, forMode: .common)
        progressTimer = timer
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
        guard var state = currentPlayerState else { return }
        // Optimistic UI update so the button responds instantly, even if the
        // App Remote is mid-reconnect and the actual command is queued.
        state.isPaused.toggle()
        currentPlayerState = state
        lastStateReceivedAt = Date()
        // Debounce incoming Spotify state for 500ms so the optimistic toggle
        // isn't immediately overwritten by the echo from the SDK.
        ignoreStateUpdatesUntil = Date().addingTimeInterval(0.5)
        if state.isPaused {
            stopProgressTimer()
            pause()
        } else {
            startProgressTimer()
            resume()
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

        let playlistsToFetch = CuratedPlaylists.all.filter { playlistCovers[$0.id] == nil }
        guard !playlistsToFetch.isEmpty else { return }

        await withTaskGroup(of: (String, String?).self) { group in
            for playlist in playlistsToFetch {
                let playlistID = playlist.id
                group.addTask {
                    guard let url = URL(string: "https://api.spotify.com/v1/playlists/\(playlistID)?fields=images") else {
                        return (playlistID, nil)
                    }
                    var request = URLRequest(url: url)
                    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

                    guard let (data, response) = try? await URLSession.shared.data(for: request),
                          (response as? HTTPURLResponse)?.statusCode == 200,
                          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                          let images = json["images"] as? [[String: Any]],
                          let imageURL = images.first?["url"] as? String else {
                        return (playlistID, nil)
                    }
                    return (playlistID, imageURL)
                }
            }

            for await (id, url) in group {
                if let url { playlistCovers[id] = url }
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
