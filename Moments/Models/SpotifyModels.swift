import Foundation

// MARK: - Local Player State

struct SpotifyPlayerState: Sendable {
    var trackName: String
    var artistName: String
    var albumName: String
    var artworkURL: URL?
    var isPaused: Bool
    var durationMs: Int
    var positionMs: Int
    var trackURI: String
}
