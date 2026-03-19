import Foundation
import FirebaseFirestore

/// A moment that has been ended and saved to the user's history.
/// Stored at: users/{uid}/moments/{momentId}
struct CompletedMoment: Codable, Identifiable, Sendable {
    @DocumentID var id: String?
    var title: String
    var vibe: String
    var playlistId: String?
    var dishIds: [String]
    var gameNumbers: [Int]
    var startedAt: Date
    var endedAt: Date

    /// A human-readable summary line, e.g. "3 dishes · 2 games"
    var summary: String {
        var parts: [String] = []
        if !dishIds.isEmpty {
            parts.append("\(dishIds.count) dish\(dishIds.count == 1 ? "" : "es")")
        }
        if !gameNumbers.isEmpty {
            parts.append("\(gameNumbers.count) game\(gameNumbers.count == 1 ? "" : "s")")
        }
        return parts.joined(separator: " · ")
    }
}
