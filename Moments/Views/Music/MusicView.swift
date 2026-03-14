import SwiftUI

// MARK: - Models (Spotify-ready — fields map to Web API responses)

struct SpotifyTrack: Identifiable {
    let id: String          // Spotify track ID
    let name: String
    let artist: String
    let album: String
    let durationMs: Int
    let spotifyURI: String  // "spotify:track:xxx"
    let artworkColor: Color // placeholder until real artwork loads
}

struct SpotifyPlaylist: Identifiable {
    let id: String          // Spotify playlist ID
    let name: String
    let description: String
    let songCount: Int
    let spotifyURI: String  // "spotify:playlist:xxx"
    let tracks: [SpotifyTrack]
    let mood: String
    let artworkColor: Color // placeholder until real artwork loads
}

// MARK: - Placeholder Data

private let sampleTracks: [String: [SpotifyTrack]] = [
    "latenight": [
        SpotifyTrack(id: "1", name: "Midnight in Copenhagen", artist: "The Nordic Ensemble", album: "Northern Lights", durationMs: 234000, spotifyURI: "spotify:track:placeholder1", artworkColor: Color(red: 0.22, green: 0.20, blue: 0.28)),
        SpotifyTrack(id: "2", name: "Candlelight", artist: "Jazzanova", album: "Of All the Things", durationMs: 312000, spotifyURI: "spotify:track:placeholder2", artworkColor: Color(red: 0.28, green: 0.22, blue: 0.20)),
        SpotifyTrack(id: "3", name: "Dusk", artist: "Khruangbin", album: "Mordechai", durationMs: 198000, spotifyURI: "spotify:track:placeholder3", artworkColor: Color(red: 0.25, green: 0.22, blue: 0.30)),
        SpotifyTrack(id: "4", name: "Twilight Zone", artist: "Nils Frahm", album: "All Melody", durationMs: 276000, spotifyURI: "spotify:track:placeholder4", artworkColor: Color(red: 0.20, green: 0.22, blue: 0.26)),
        SpotifyTrack(id: "5", name: "After Hours", artist: "Tom Misch", album: "Geography", durationMs: 248000, spotifyURI: "spotify:track:placeholder5", artworkColor: Color(red: 0.26, green: 0.24, blue: 0.22)),
        SpotifyTrack(id: "6", name: "Slow Burn", artist: "Kacey Musgraves", album: "Golden Hour", durationMs: 252000, spotifyURI: "spotify:track:placeholder6", artworkColor: Color(red: 0.30, green: 0.25, blue: 0.20)),
    ],
    "dinner": [
        SpotifyTrack(id: "7", name: "Lovely Day", artist: "Bill Withers", album: "Menagerie", durationMs: 258000, spotifyURI: "spotify:track:placeholder7", artworkColor: Color(red: 0.28, green: 0.26, blue: 0.20)),
        SpotifyTrack(id: "8", name: "Affection", artist: "Jinsang", album: "Life", durationMs: 174000, spotifyURI: "spotify:track:placeholder8", artworkColor: Color(red: 0.24, green: 0.26, blue: 0.22)),
        SpotifyTrack(id: "9", name: "Best Part", artist: "Daniel Caesar", album: "Freudian", durationMs: 219000, spotifyURI: "spotify:track:placeholder9", artworkColor: Color(red: 0.22, green: 0.24, blue: 0.28)),
        SpotifyTrack(id: "10", name: "Put It All on Me", artist: "Ed Sheeran", album: "No.6", durationMs: 197000, spotifyURI: "spotify:track:placeholder10", artworkColor: Color(red: 0.26, green: 0.22, blue: 0.24)),
        SpotifyTrack(id: "11", name: "Golden", artist: "Jill Scott", album: "Beautifully Human", durationMs: 241000, spotifyURI: "spotify:track:placeholder11", artworkColor: Color(red: 0.30, green: 0.26, blue: 0.20)),
    ],
    "sunday": [
        SpotifyTrack(id: "12", name: "Sunday Morning", artist: "Maroon 5", album: "Songs About Jane", durationMs: 295000, spotifyURI: "spotify:track:placeholder12", artworkColor: Color(red: 0.26, green: 0.28, blue: 0.24)),
        SpotifyTrack(id: "13", name: "Here Comes the Sun", artist: "The Beatles", album: "Abbey Road", durationMs: 185000, spotifyURI: "spotify:track:placeholder13", artworkColor: Color(red: 0.30, green: 0.28, blue: 0.22)),
        SpotifyTrack(id: "14", name: "Banana Pancakes", artist: "Jack Johnson", album: "In Between Dreams", durationMs: 191000, spotifyURI: "spotify:track:placeholder14", artworkColor: Color(red: 0.24, green: 0.28, blue: 0.22)),
        SpotifyTrack(id: "15", name: "Dreams", artist: "Fleetwood Mac", album: "Rumours", durationMs: 257000, spotifyURI: "spotify:track:placeholder15", artworkColor: Color(red: 0.28, green: 0.24, blue: 0.26)),
    ],
    "party": [
        SpotifyTrack(id: "16", name: "Get Lucky", artist: "Daft Punk", album: "Random Access Memories", durationMs: 369000, spotifyURI: "spotify:track:placeholder16", artworkColor: Color(red: 0.22, green: 0.22, blue: 0.28)),
        SpotifyTrack(id: "17", name: "One More Time", artist: "Daft Punk", album: "Discovery", durationMs: 321000, spotifyURI: "spotify:track:placeholder17", artworkColor: Color(red: 0.24, green: 0.20, blue: 0.28)),
        SpotifyTrack(id: "18", name: "Superstition", artist: "Stevie Wonder", album: "Talking Book", durationMs: 285000, spotifyURI: "spotify:track:placeholder18", artworkColor: Color(red: 0.28, green: 0.24, blue: 0.20)),
        SpotifyTrack(id: "19", name: "September", artist: "Earth, Wind & Fire", album: "The Best of", durationMs: 215000, spotifyURI: "spotify:track:placeholder19", artworkColor: Color(red: 0.30, green: 0.22, blue: 0.22)),
        SpotifyTrack(id: "20", name: "Le Freak", artist: "Chic", album: "C'est Chic", durationMs: 331000, spotifyURI: "spotify:track:placeholder20", artworkColor: Color(red: 0.26, green: 0.20, blue: 0.26)),
    ],
]

private let samplePlaylists: [SpotifyPlaylist] = [
    SpotifyPlaylist(id: "p1", name: "Late Night Cocktails", description: "Smooth jazz and lo-fi for wine nights and candlelit evenings", songCount: 24, spotifyURI: "spotify:playlist:placeholder1", tracks: sampleTracks["latenight"]!, mood: "Evening", artworkColor: Color(red: 0.22, green: 0.20, blue: 0.28)),
    SpotifyPlaylist(id: "p2", name: "Dinner Party Grooves", description: "Soulful beats to keep the conversation flowing", songCount: 18, spotifyURI: "spotify:playlist:placeholder2", tracks: sampleTracks["dinner"]!, mood: "Evening", artworkColor: Color(red: 0.28, green: 0.26, blue: 0.20)),
    SpotifyPlaylist(id: "p3", name: "Easy Sunday", description: "Lazy mornings, fresh coffee, golden light", songCount: 32, spotifyURI: "spotify:playlist:placeholder3", tracks: sampleTracks["sunday"]!, mood: "Morning", artworkColor: Color(red: 0.26, green: 0.28, blue: 0.24)),
    SpotifyPlaylist(id: "p4", name: "Party Starter", description: "Guaranteed to get everyone on their feet", songCount: 21, spotifyURI: "spotify:playlist:placeholder4", tracks: sampleTracks["party"]!, mood: "Night", artworkColor: Color(red: 0.24, green: 0.20, blue: 0.28)),
]

// MARK: - Music View

struct MusicView: View {
    @State private var currentTrackID = sampleTracks["latenight"]?.first?.id
    @State private var isPlaying = false
    @State private var selectedMood: String? = nil

    private let moods = ["All", "Morning", "Evening", "Night"]

    private var queue: [SpotifyTrack] {
        samplePlaylists.flatMap(\.tracks)
    }

    private var currentTrack: SpotifyTrack? {
        guard let currentTrackID else { return queue.first }
        return queue.first(where: { $0.id == currentTrackID }) ?? queue.first
    }

    private var filteredPlaylists: [SpotifyPlaylist] {
        guard let mood = selectedMood, mood != "All" else { return samplePlaylists }
        return samplePlaylists.filter { $0.mood == mood }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack(alignment: .top) {
                    SectionHeader("Music", subtitle: "Set the mood for every moment")

                    Spacer()

                    // Spotify badge
                    SpotifyBadge()
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 24)

                // Now Playing
                if let track = currentTrack {
                    NowPlayingCard(
                        track: track,
                        isPlaying: $isPlaying,
                        onPrevious: { cycleTrack(by: -1) },
                        onNext: { cycleTrack(by: 1) }
                    )
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)
                }

                // Mood filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(moods, id: \.self) { mood in
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedMood = (selectedMood == mood || mood == "All") && selectedMood != nil && mood == "All" ? nil : mood
                                }
                            } label: {
                                PillTag(label: mood, filled: selectedMood == mood || (mood == "All" && selectedMood == nil))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 20)

                // Playlists
                Text("PLAYLISTS")
                    .font(.system(size: 10, weight: .light))
                    .tracking(3)
                    .foregroundColor(MomentsStyle.secondaryText)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 14)

                VStack(spacing: 0) {
                    ForEach(filteredPlaylists) { playlist in
                        NavigationLink(value: playlist.id) {
                            PlaylistRow(playlist: playlist)
                        }
                        .buttonStyle(.plain)

                        if playlist.id != filteredPlaylists.last?.id {
                            Rectangle()
                                .frame(height: 0.5)
                                .foregroundColor(MomentsStyle.border)
                                .padding(.horizontal, 24)
                        }
                    }
                }

                // Open Spotify CTA
                Button {
                    openSpotify(uri: "spotify:")
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 12, weight: .light))
                        Text("OPEN SPOTIFY")
                            .font(.system(size: 10, weight: .light))
                            .tracking(3)
                    }
                    .foregroundColor(MomentsStyle.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .overlay(
                        Capsule()
                            .stroke(MomentsStyle.border, lineWidth: 0.5)
                    )
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)

                Spacer(minLength: 32)
            }
        }
        .background(MomentsStyle.background)
        .navigationDestination(for: String.self) { playlistID in
            if let playlist = samplePlaylists.first(where: { $0.id == playlistID }) {
                PlaylistDetailView(playlist: playlist)
            }
        }
    }
}

// MARK: - Spotify Badge

struct SpotifyBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Color(red: 0.12, green: 0.84, blue: 0.38))
                .frame(width: 8, height: 8)
            Text("Spotify")
                .font(.system(size: 10, weight: .light))
                .foregroundColor(MomentsStyle.secondaryText)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .overlay(
            Capsule()
                .stroke(MomentsStyle.border, lineWidth: 0.5)
        )
    }
}

// MARK: - Now Playing Card

struct NowPlayingCard: View {
    let track: SpotifyTrack
    @Binding var isPlaying: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void
    @State private var progress: Double = 0.35

    var body: some View {
        HairlineCard {
            VStack(spacing: 16) {
                // Album art placeholder
                RoundedRectangle(cornerRadius: 8)
                    .fill(track.artworkColor)
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "music.note")
                                .font(.system(size: 32, weight: .light))
                                .foregroundColor(.white.opacity(0.4))

                            Text(track.album)
                                .font(.system(size: 10, weight: .light))
                                .tracking(2)
                                .foregroundColor(.white.opacity(0.5))
                        }
                    )

                // Track info
                VStack(spacing: 4) {
                    Text(track.name)
                        .font(MomentsStyle.systemMedium(16))
                        .foregroundColor(MomentsStyle.primaryText)

                    Text(track.artist)
                        .font(MomentsStyle.systemLight(13))
                        .foregroundColor(MomentsStyle.secondaryText)
                }

                // Progress bar
                VStack(spacing: 6) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .frame(height: 1.5)
                                .foregroundColor(MomentsStyle.border)

                            Rectangle()
                                .frame(width: geometry.size.width * progress, height: 1.5)
                                .foregroundColor(MomentsStyle.primaryText)
                        }
                    }
                    .frame(height: 1.5)

                    HStack {
                        Text(formatDuration(Int(Double(track.durationMs) * progress)))
                            .font(.system(size: 10, weight: .light))
                            .foregroundColor(MomentsStyle.secondaryText)

                        Spacer()

                        Text(formatDuration(track.durationMs))
                            .font(.system(size: 10, weight: .light))
                            .foregroundColor(MomentsStyle.secondaryText)
                    }
                }

                // Playback controls
                HStack(spacing: 40) {
                    Button(action: onPrevious) {
                        Image(systemName: "backward.end")
                            .font(.system(size: 18, weight: .light))
                            .foregroundColor(MomentsStyle.primaryText)
                    }

                    Button {
                        isPlaying.toggle()
                    } label: {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 40, weight: .light))
                            .foregroundColor(MomentsStyle.primaryText)
                    }

                    Button(action: onNext) {
                        Image(systemName: "forward.end")
                            .font(.system(size: 18, weight: .light))
                            .foregroundColor(MomentsStyle.primaryText)
                    }
                }

                // Open in Spotify link
                Button {
                    openSpotify(uri: track.spotifyURI)
                } label: {
                    Text("PLAY ON SPOTIFY")
                        .font(.system(size: 9, weight: .light))
                        .tracking(2)
                        .foregroundColor(MomentsStyle.secondaryText)
                }
                .padding(.top, 4)
            }
        }
    }
}

// MARK: - Playlist Row

struct PlaylistRow: View {
    let playlist: SpotifyPlaylist

    var body: some View {
        HStack(spacing: 14) {
            // Artwork placeholder
            RoundedRectangle(cornerRadius: 6)
                .fill(playlist.artworkColor)
                .frame(width: 56, height: 56)
                .overlay(
                    Image(systemName: "music.note.list")
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(.white.opacity(0.5))
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(playlist.name)
                    .font(MomentsStyle.systemMedium(15))
                    .foregroundColor(MomentsStyle.primaryText)

                Text(playlist.description)
                    .font(MomentsStyle.systemLight(12))
                    .foregroundColor(MomentsStyle.secondaryText)
                    .lineLimit(1)

                Text("\(playlist.songCount) songs")
                    .font(.system(size: 10, weight: .light))
                    .foregroundColor(MomentsStyle.inactive)
                    .padding(.top, 1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .light))
                .foregroundColor(MomentsStyle.inactive)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
    }
}

// MARK: - Helpers

private func formatDuration(_ ms: Int) -> String {
    let totalSeconds = ms / 1000
    let minutes = totalSeconds / 60
    let seconds = totalSeconds % 60
    return String(format: "%d:%02d", minutes, seconds)
}

private extension MusicView {
    func cycleTrack(by offset: Int) {
        guard !queue.isEmpty else { return }

        let currentIndex: Int
        if let currentTrackID,
           let index = queue.firstIndex(where: { $0.id == currentTrackID }) {
            currentIndex = index
        } else {
            currentIndex = 0
        }

        let nextIndex = (currentIndex + offset + queue.count) % queue.count
        currentTrackID = queue[nextIndex].id
        isPlaying = true
    }
}

private func openSpotify(uri: String) {
    guard let url = URL(string: uri) else { return }
    if UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url)
    } else if let webURL = URL(string: "https://open.spotify.com") {
        UIApplication.shared.open(webURL)
    }
}

#Preview {
    NavigationStack {
        MusicView()
    }
}
