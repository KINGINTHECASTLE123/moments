import Foundation

struct CuratedPlaylist: Identifiable, Hashable {
    let id: String          // Spotify playlist ID
    let name: String
    let subtitle: String
    let mood: String        // "intimate", "energetic", "chill"
    let spotifyURI: String
    let timeOfDay: String   // "morning", "afternoon", "evening", "lateNight"
    var coverImageURL: String?  // fetched from Spotify API at runtime

    var spotifyURL: URL? {
        URL(string: "https://open.spotify.com/playlist/\(id)")
    }
}

enum CuratedPlaylists {
    static var all: [CuratedPlaylist] = [
        CuratedPlaylist(
            id: "6rFUD4nYmvlQX34risW6XV",
            name: "Dinner Party Grooves",
            subtitle: "Warm jazz, classic soul, and candlelit energy",
            mood: "intimate",
            spotifyURI: "spotify:playlist:6rFUD4nYmvlQX34risW6XV",
            timeOfDay: "evening"
        ),
        CuratedPlaylist(
            id: "6A3aUoXu4hgYxsJIUmaC91",
            name: "Date Night",
            subtitle: "Slow jams and candlelit soul for two",
            mood: "intimate",
            spotifyURI: "spotify:playlist:6A3aUoXu4hgYxsJIUmaC91",
            timeOfDay: "lateNight"
        ),
        CuratedPlaylist(
            id: "33O5FHsGRzd4xN5qSpy6nk",
            name: "Upbeat Evening",
            subtitle: "Feel-good funk and energy for the night ahead",
            mood: "energetic",
            spotifyURI: "spotify:playlist:33O5FHsGRzd4xN5qSpy6nk",
            timeOfDay: "evening"
        ),
        CuratedPlaylist(
            id: "5kM6ImFIZGUAysEDIXr3ZP",
            name: "Golden Hour",
            subtitle: "Warm afternoon soul and easy-going grooves",
            mood: "chill",
            spotifyURI: "spotify:playlist:5kM6ImFIZGUAysEDIXr3ZP",
            timeOfDay: "afternoon"
        ),
        CuratedPlaylist(
            id: "3ONiNO6VmcdXEswRiIQg2J",
            name: "Easy Sunday Morning",
            subtitle: "Soft starts and slow sips",
            mood: "chill",
            spotifyURI: "spotify:playlist:3ONiNO6VmcdXEswRiIQg2J",
            timeOfDay: "morning"
        ),
        CuratedPlaylist(
            id: "2HFa12Q9qbAGjAHFiCHvMz",
            name: "Late Night Wind-Down",
            subtitle: "Intimate, mellow tones for when the night gets quiet",
            mood: "intimate",
            spotifyURI: "spotify:playlist:2HFa12Q9qbAGjAHFiCHvMz",
            timeOfDay: "lateNight"
        ),
    ]

    static func featured(for hour: Int) -> CuratedPlaylist {
        let timeOfDay: String
        switch hour {
        case 0..<12: timeOfDay = "morning"
        case 12..<18: timeOfDay = "afternoon"
        case 18..<22: timeOfDay = "evening"
        default: timeOfDay = "lateNight"
        }
        return all.first(where: { $0.timeOfDay == timeOfDay }) ?? all[0]
    }

    static func filtered(by mood: String) -> [CuratedPlaylist] {
        if mood == "all" { return all }
        return all.filter { $0.mood == mood }
    }
}
