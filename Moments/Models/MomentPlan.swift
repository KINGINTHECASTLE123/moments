import Foundation

struct MomentPlan: Codable, Identifiable {
    let id: UUID
    var title: String
    var vibe: String                    // "dinner-party", "game-night", "date-night", "custom"
    var playlistId: String?             // reference to CuratedPlaylists
    var dishIds: [String]               // references to dishes collection
    var gameNumbers: [Int]              // references to game numbers in GameModels
    var createdAt: Date
    var isActive: Bool                  // currently in progress
    var startedAt: Date?                // when "Start Evening" was tapped

    init(
        title: String = "",
        vibe: String = "custom",
        playlistId: String? = nil,
        dishIds: [String] = [],
        gameNumbers: [Int] = []
    ) {
        self.id = UUID()
        self.title = title
        self.vibe = vibe
        self.playlistId = playlistId
        self.dishIds = dishIds
        self.gameNumbers = gameNumbers
        self.createdAt = Date()
        self.isActive = false
        self.startedAt = nil
    }
}
