import SwiftUI

struct PlaylistDetailView: View {
    let playlist: SpotifyPlaylist

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Playlist header
                VStack(spacing: 16) {
                    // Artwork
                    RoundedRectangle(cornerRadius: 12)
                        .fill(playlist.artworkColor)
                        .frame(width: 200, height: 200)
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: "music.note.list")
                                    .font(.system(size: 36, weight: .light))
                                    .foregroundColor(.white.opacity(0.4))

                                Text(playlist.mood.uppercased())
                                    .font(.system(size: 9, weight: .light))
                                    .tracking(3)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        )

                    Text(playlist.name)
                        .font(MomentsStyle.georgiaItalic(24))
                        .foregroundColor(MomentsStyle.primaryText)

                    Text(playlist.description)
                        .font(MomentsStyle.systemLight(14))
                        .foregroundColor(MomentsStyle.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    HStack(spacing: 16) {
                        Text("\(playlist.songCount) songs")
                            .font(.system(size: 11, weight: .light))
                            .foregroundColor(MomentsStyle.secondaryText)

                        Circle()
                            .frame(width: 3, height: 3)
                            .foregroundColor(MomentsStyle.border)

                        Text(playlist.mood)
                            .font(.system(size: 11, weight: .light))
                            .foregroundColor(MomentsStyle.secondaryText)
                    }

                    // Action buttons
                    HStack(spacing: 14) {
                        // Open in Spotify (primary)
                        Button {
                            openSpotifyURI(playlist.spotifyURI)
                        } label: {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color(red: 0.12, green: 0.84, blue: 0.38))
                                    .frame(width: 6, height: 6)
                                Text("PLAY ON SPOTIFY")
                                    .font(.system(size: 10, weight: .light))
                                    .tracking(2)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(MomentsStyle.primaryText)
                            .clipShape(Capsule())
                        }

                        // Share
                        ShareLink(item: playlistShareItem) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 16, weight: .light))
                                .foregroundColor(MomentsStyle.primaryText)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(MomentsStyle.border, lineWidth: 0.5)
                                )
                        }
                    }
                    .padding(.top, 4)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 16)
                .padding(.bottom, 28)

                // Divider
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(MomentsStyle.border)

                // Track list header
                Text("TRACKLIST")
                    .font(.system(size: 10, weight: .light))
                    .tracking(3)
                    .foregroundColor(MomentsStyle.secondaryText)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 14)

                // Tracks
                ForEach(Array(playlist.tracks.enumerated()), id: \.element.id) { index, track in
                    TrackRow(track: track, index: index + 1)

                    if track.id != playlist.tracks.last?.id {
                        Rectangle()
                            .frame(height: 0.5)
                            .foregroundColor(MomentsStyle.border)
                            .padding(.leading, 62)
                            .padding(.trailing, 24)
                    }
                }

                Spacer(minLength: 32)
            }
        }
        .background(MomentsStyle.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(playlist.name)
                    .font(MomentsStyle.georgiaItalic(18))
                    .foregroundColor(MomentsStyle.primaryText)
            }
        }
    }

    private func openSpotifyURI(_ uri: String) {
        guard let url = URL(string: uri) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else if let webURL = URL(string: "https://open.spotify.com") {
            UIApplication.shared.open(webURL)
        }
    }

    private var playlistShareItem: String {
        spotifyWebURL(from: playlist.spotifyURI)?.absoluteString ?? playlist.name
    }
}

// MARK: - Track Row

struct TrackRow: View {
    let track: SpotifyTrack
    let index: Int

    var body: some View {
        Button {
            openTrack()
        } label: {
            HStack(spacing: 14) {
                // Track number
                Text("\(index)")
                    .font(MomentsStyle.georgiaItalic(16))
                    .foregroundColor(MomentsStyle.inactive)
                    .frame(width: 24, alignment: .center)

                // Track artwork
                RoundedRectangle(cornerRadius: 4)
                    .fill(track.artworkColor)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "music.note")
                            .font(.system(size: 12, weight: .light))
                            .foregroundColor(.white.opacity(0.5))
                    )

                // Track info
                VStack(alignment: .leading, spacing: 2) {
                    Text(track.name)
                        .font(MomentsStyle.systemRegular(14))
                        .foregroundColor(MomentsStyle.primaryText)

                    Text(track.artist)
                        .font(MomentsStyle.systemLight(12))
                        .foregroundColor(MomentsStyle.secondaryText)
                }

                Spacer()

                // Duration
                Text(formatTrackDuration(track.durationMs))
                    .font(.system(size: 11, weight: .light))
                    .foregroundColor(MomentsStyle.inactive)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
    }

    private func openTrack() {
        guard let url = URL(string: track.spotifyURI) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

private func formatTrackDuration(_ ms: Int) -> String {
    let totalSeconds = ms / 1000
    let minutes = totalSeconds / 60
    let seconds = totalSeconds % 60
    return String(format: "%d:%02d", minutes, seconds)
}

private func spotifyWebURL(from uri: String) -> URL? {
    let components = uri.split(separator: ":")
    guard components.count == 3 else { return nil }
    let kind = components[1]
    let id = components[2]
    return URL(string: "https://open.spotify.com/\(kind)/\(id)")
}

#Preview {
    NavigationStack {
        PlaylistDetailView(playlist: SpotifyPlaylist(
            id: "p1",
            name: "Late Night Cocktails",
            description: "Smooth jazz and lo-fi for wine nights",
            songCount: 24,
            spotifyURI: "spotify:playlist:placeholder1",
            tracks: [
                SpotifyTrack(id: "1", name: "Midnight in Copenhagen", artist: "The Nordic Ensemble", album: "Northern Lights", durationMs: 234000, spotifyURI: "spotify:track:placeholder1", artworkColor: Color(red: 0.22, green: 0.20, blue: 0.28)),
                SpotifyTrack(id: "2", name: "Candlelight", artist: "Jazzanova", album: "Of All the Things", durationMs: 312000, spotifyURI: "spotify:track:placeholder2", artworkColor: Color(red: 0.28, green: 0.22, blue: 0.20)),
            ],
            mood: "Evening",
            artworkColor: Color(red: 0.22, green: 0.20, blue: 0.28)
        ))
    }
}
