import Foundation

// MARK: - Web API Response Models

struct SpotifyImage: Codable {
    let url: String
    let width: Int?
    let height: Int?
}

struct SpotifyArtist: Codable {
    let id: String?
    let name: String
}

struct SpotifyAlbum: Codable {
    let id: String?
    let name: String
    let images: [SpotifyImage]

    init(id: String?, name: String, images: [SpotifyImage]) {
        self.id = id
        self.name = name
        self.images = images
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        images = try container.decodeIfPresent([SpotifyImage].self, forKey: .images) ?? []
    }
}

struct SpotifyTrackItem: Codable, Identifiable, Sendable {
    let id: String
    let name: String
    let artists: [SpotifyArtist]
    let album: SpotifyAlbum
    let durationMs: Int
    let uri: String

    var artistName: String {
        artists.map(\.name).joined(separator: ", ")
    }

    var artworkURL: URL? {
        album.images.first.flatMap { URL(string: $0.url) }
    }

    enum CodingKeys: String, CodingKey {
        case id, name, artists, album, uri
        case durationMs = "duration_ms"
    }

    init(id: String, name: String, artists: [SpotifyArtist], album: SpotifyAlbum, durationMs: Int, uri: String) {
        self.id = id
        self.name = name
        self.artists = artists
        self.album = album
        self.durationMs = durationMs
        self.uri = uri
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let uri = try container.decode(String.self, forKey: .uri)

        id = try container.decodeIfPresent(String.self, forKey: .id) ?? uri
        name = try container.decode(String.self, forKey: .name)
        artists = try container.decodeIfPresent([SpotifyArtist].self, forKey: .artists) ?? []
        album = try container.decodeIfPresent(SpotifyAlbum.self, forKey: .album) ?? SpotifyAlbum(id: nil, name: "", images: [])
        durationMs = try container.decodeIfPresent(Int.self, forKey: .durationMs) ?? 0
        self.uri = uri
    }
}

struct SpotifyPlaylistItem: Codable, Identifiable, Sendable {
    let id: String
    let name: String
    let description: String?
    let images: [SpotifyImage]
    let tracks: SpotifyPlaylistTrackInfo
    let uri: String
    let owner: SpotifyOwner

    var artworkURL: URL? {
        images.first.flatMap { URL(string: $0.url) }
    }

    var trackCount: Int {
        tracks.total
    }

    init(id: String, name: String, description: String?, images: [SpotifyImage], tracks: SpotifyPlaylistTrackInfo, uri: String, owner: SpotifyOwner) {
        self.id = id
        self.name = name
        self.description = description
        self.images = images
        self.tracks = tracks
        self.uri = uri
        self.owner = owner
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, description, images, tracks, uri, owner
        // Feb 2026 migration renamed "tracks" to "items" in playlist objects
        case items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        images = try container.decodeIfPresent([SpotifyImage].self, forKey: .images) ?? []
        // Try "tracks" first, then fall back to "items" (Feb 2026 migration)
        if let t = try? container.decodeIfPresent(SpotifyPlaylistTrackInfo.self, forKey: .tracks) {
            tracks = t
        } else {
            tracks = try container.decodeIfPresent(SpotifyPlaylistTrackInfo.self, forKey: .items) ?? SpotifyPlaylistTrackInfo(total: 0)
        }
        uri = try container.decode(String.self, forKey: .uri)
        owner = try container.decodeIfPresent(SpotifyOwner.self, forKey: .owner) ?? SpotifyOwner(displayName: nil, id: "")
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(images, forKey: .images)
        try container.encode(tracks, forKey: .tracks)
        try container.encode(uri, forKey: .uri)
        try container.encode(owner, forKey: .owner)
    }
}

struct SpotifyPlaylistTrackInfo: Codable {
    let total: Int
}

struct SpotifyOwner: Codable {
    let displayName: String?
    let id: String

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case id
    }
}

struct SpotifyPlaylistsResponse: Codable {
    let items: [SpotifyPlaylistItem]
    let total: Int
    let next: String?
}

struct SpotifyPlaylistTracksResponse: Codable {
    let items: [SpotifyPlaylistTrackWrapper]
    let total: Int
    let next: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        items = try container.decodeIfPresent([SpotifyPlaylistTrackWrapper].self, forKey: .items) ?? []
        total = try container.decodeIfPresent(Int.self, forKey: .total) ?? 0
        next = try container.decodeIfPresent(String.self, forKey: .next)
    }
}

struct SpotifyPlaylistTrackWrapper: Codable {
    let track: SpotifyTrackItem?

    private enum CodingKeys: String, CodingKey {
        case track
        case item
    }

    init(track: SpotifyTrackItem?) {
        self.track = track
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // The /items endpoint (Feb 2026+) uses "item", older /tracks uses "track"
        if let item = try? container.decodeIfPresent(SpotifyTrackItem.self, forKey: .item) {
            track = item
        } else {
            track = try? container.decodeIfPresent(SpotifyTrackItem.self, forKey: .track)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(track, forKey: .track)
    }
}

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
