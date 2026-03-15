import SwiftUI

struct PlaylistDetailView: View {
    @Environment(MusicViewModel.self) private var musicViewModel
    let playlistID: String
    @State private var tracks: [SpotifyTrackItem] = []
    @State private var isLoading = true

    private var playlist: SpotifyPlaylistItem? {
        musicViewModel.playlists.first(where: { $0.id == playlistID })
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Playlist header
                VStack(spacing: 16) {
                    // Artwork
                    if let artworkURL = playlist?.artworkURL {
                        AsyncImage(url: artworkURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            artworkPlaceholder
                        }
                        .frame(width: 200, height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        artworkPlaceholder
                    }

                    if let playlist {
                        Text(playlist.name)
                            .font(MomentsStyle.georgiaItalic(24))
                            .foregroundColor(MomentsStyle.primaryText)

                        if let description = playlist.description, !description.isEmpty {
                            Text(description)
                                .font(MomentsStyle.systemLight(14))
                                .foregroundColor(MomentsStyle.secondaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }

                        Text("\(playlist.trackCount) songs")
                            .font(.system(size: 11, weight: .light))
                            .foregroundColor(MomentsStyle.secondaryText)

                        // Play button
                        Button {
                            musicViewModel.play(uri: playlist.uri)
                        } label: {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color(red: 0.12, green: 0.84, blue: 0.38))
                                    .frame(width: 6, height: 6)
                                Text("PLAY")
                                    .font(.system(size: 10, weight: .light))
                                    .tracking(2)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(MomentsStyle.primaryText)
                            .clipShape(Capsule())
                        }
                        .padding(.top, 4)
                    }
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

                if isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .padding(.top, 20)
                } else if let error = musicViewModel.errorMessage, tracks.isEmpty {
                    Text(error)
                        .font(MomentsStyle.systemLight(13))
                        .foregroundColor(.red.opacity(0.8))
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                } else if tracks.isEmpty {
                    Text("No songs available in this playlist.")
                        .font(MomentsStyle.systemLight(13))
                        .foregroundColor(MomentsStyle.secondaryText)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                } else {
                    // Tracks
                    ForEach(Array(tracks.enumerated()), id: \.element.id) { index, track in
                        TrackRow(track: track, index: index + 1) {
                            musicViewModel.play(uri: track.uri)
                        }

                        if track.id != tracks.last?.id {
                            Rectangle()
                                .frame(height: 0.5)
                                .foregroundColor(MomentsStyle.border)
                                .padding(.leading, 62)
                                .padding(.trailing, 24)
                        }
                    }
                }

                Spacer(minLength: 32)
            }
        }
        .background(MomentsStyle.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(playlist?.name ?? "Playlist")
                    .font(MomentsStyle.georgiaItalic(18))
                    .foregroundColor(MomentsStyle.primaryText)
            }
        }
        .task(id: playlistID) {
            print("PlaylistDetailView loading tracks for playlistID: \(playlistID)")
            tracks = await musicViewModel.fetchTracks(playlistID: playlistID)
            print("PlaylistDetailView loaded \(tracks.count) tracks for playlistID: \(playlistID)")
            isLoading = false
        }
    }

    private var artworkPlaceholder: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(MomentsStyle.surfaceSecondary)
            .frame(width: 200, height: 200)
            .overlay(
                Image(systemName: "music.note.list")
                    .font(.system(size: 36, weight: .light))
                    .foregroundColor(MomentsStyle.inactive)
            )
    }
}

// MARK: - Track Row

struct TrackRow: View {
    let track: SpotifyTrackItem
    let index: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Track number
                Text("\(index)")
                    .font(MomentsStyle.georgiaItalic(16))
                    .foregroundColor(MomentsStyle.inactive)
                    .frame(width: 24, alignment: .center)

                // Track artwork
                if let artworkURL = track.artworkURL {
                    AsyncImage(url: artworkURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(MomentsStyle.surfaceSecondary)
                            .overlay(
                                Image(systemName: "music.note")
                                    .font(.system(size: 12, weight: .light))
                                    .foregroundColor(MomentsStyle.inactive)
                            )
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                } else {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(MomentsStyle.surfaceSecondary)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "music.note")
                                .font(.system(size: 12, weight: .light))
                                .foregroundColor(MomentsStyle.inactive)
                        )
                }

                // Track info
                VStack(alignment: .leading, spacing: 2) {
                    Text(track.name)
                        .font(MomentsStyle.systemRegular(14))
                        .foregroundColor(MomentsStyle.primaryText)
                        .lineLimit(1)

                    Text(track.artistName)
                        .font(MomentsStyle.systemLight(12))
                        .foregroundColor(MomentsStyle.secondaryText)
                        .lineLimit(1)
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
}

private func formatTrackDuration(_ ms: Int) -> String {
    let totalSeconds = ms / 1000
    let minutes = totalSeconds / 60
    let seconds = totalSeconds % 60
    return String(format: "%d:%02d", minutes, seconds)
}

#Preview {
    NavigationStack {
        PlaylistDetailView(playlistID: "test")
            .environment(MusicViewModel())
    }
}
