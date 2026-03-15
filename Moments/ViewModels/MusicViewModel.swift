import Foundation

@Observable
final class MusicViewModel {
    private let spotifyService = SpotifyService()
    private var progressTimer: Timer?
    private var lastStateReceivedAt: Date?

    var isConnected = false
    var playlists: [SpotifyPlaylistItem] = []
    var currentPlayerState: SpotifyPlayerState?
    var isLoading = false
    var errorMessage: String?

    init() {
        spotifyService.onConnected = { [weak self] in
            Task { @MainActor in
                self?.isConnected = true
                await self?.fetchPlaylists()
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

    @MainActor
    private func startProgressTimer() {
        stopProgressTimer()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tickProgress()
            }
        }
    }

    @MainActor
    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }

    @MainActor
    private func tickProgress() {
        guard var state = currentPlayerState, !state.isPaused,
              let receivedAt = lastStateReceivedAt else { return }
        let elapsed = Int(Date().timeIntervalSince(receivedAt) * 1000)
        state.positionMs = min(state.positionMs + elapsed, state.durationMs)
        currentPlayerState = state
        lastStateReceivedAt = Date()
    }

    // MARK: - Authorization

    @MainActor
    func authorize() {
        errorMessage = nil
        errorMessage = spotifyService.authorize()
    }

    @MainActor
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

    // MARK: - Data Fetching

    @MainActor
    func fetchPlaylists() async {
        isLoading = true
        errorMessage = nil
        do {
            playlists = try await spotifyService.fetchUserPlaylists()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func fetchTracks(playlistID: String) async -> [SpotifyTrackItem] {
        do {
            return try await spotifyService.fetchPlaylistTracks(playlistID: playlistID)
        } catch {
            print("MusicViewModel fetchTracks failed for \(playlistID): \(error.localizedDescription)")
            await MainActor.run { errorMessage = error.localizedDescription }
            return []
        }
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

    // MARK: - App Remote Access (for scene lifecycle)

    var appRemote: Any {
        spotifyService.appRemote
    }
}
