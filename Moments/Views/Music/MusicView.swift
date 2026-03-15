import SwiftUI

// MARK: - Music View

struct MusicView: View {
    @Environment(MusicViewModel.self) private var musicViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack(alignment: .top) {
                    SectionHeader("Music", subtitle: "Set the mood for every moment")

                    Spacer()

                    SpotifyBadge(isConnected: musicViewModel.isConnected)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 24)

                if musicViewModel.isConnected {
                    connectedContent
                } else {
                    connectPrompt
                }

                Spacer(minLength: 32)
            }
        }
        .background(MomentsStyle.background)
        .refreshable {
            if musicViewModel.isConnected {
                await musicViewModel.fetchPlaylists()
            }
        }
        .navigationDestination(for: String.self) { playlistID in
            PlaylistDetailView(playlistID: playlistID)
        }
    }

    // MARK: - Connected Content

    @ViewBuilder
    private var connectedContent: some View {
        // Now Playing
        if let state = musicViewModel.currentPlayerState {
            NowPlayingCard(
                playerState: state,
                onPlayPause: { musicViewModel.togglePlayback() },
                onPrevious: { musicViewModel.skipPrevious() },
                onNext: { musicViewModel.skipNext() }
            )
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
        }

        // Playlists header
        Text("YOUR PLAYLISTS")
            .font(.system(size: 10, weight: .light))
            .tracking(3)
            .foregroundColor(MomentsStyle.secondaryText)
            .padding(.horizontal, 24)
            .padding(.bottom, 14)

        if musicViewModel.isLoading && musicViewModel.playlists.isEmpty {
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
            .padding(.top, 40)
        } else if let error = musicViewModel.errorMessage, musicViewModel.playlists.isEmpty {
            Text(error)
                .font(MomentsStyle.systemLight(13))
                .foregroundColor(.red.opacity(0.8))
                .padding(.horizontal, 24)
        } else {
            VStack(spacing: 0) {
                ForEach(musicViewModel.playlists) { playlist in
                    NavigationLink(value: playlist.id) {
                        PlaylistRow(playlist: playlist)
                    }
                    .buttonStyle(.plain)

                    if playlist.id != musicViewModel.playlists.last?.id {
                        Rectangle()
                            .frame(height: 0.5)
                            .foregroundColor(MomentsStyle.border)
                            .padding(.horizontal, 24)
                    }
                }
            }
        }
    }

    // MARK: - Connect Prompt

    private var connectPrompt: some View {
        VStack(spacing: 20) {
            HairlineCard {
                VStack(spacing: 16) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(MomentsStyle.secondaryText)

                    Text("Connect your Spotify account to play music, browse your playlists, and control playback directly from Moments.")
                        .font(MomentsStyle.systemLight(14))
                        .foregroundColor(MomentsStyle.secondaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)

                    Button {
                        musicViewModel.authorize()
                    } label: {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color(red: 0.12, green: 0.84, blue: 0.38))
                                .frame(width: 8, height: 8)
                            Text("CONNECT SPOTIFY")
                                .font(.system(size: 10, weight: .light))
                                .tracking(3)
                        }
                        .foregroundColor(MomentsStyle.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(MomentsStyle.primaryText)
                        .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 24)

            if let error = musicViewModel.errorMessage {
                Text(error)
                    .font(MomentsStyle.systemLight(12))
                    .foregroundColor(.red.opacity(0.8))
                    .padding(.horizontal, 24)
            }
        }
    }
}

// MARK: - Spotify Badge

struct SpotifyBadge: View {
    var isConnected: Bool

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(isConnected ? Color(red: 0.12, green: 0.84, blue: 0.38) : MomentsStyle.inactive)
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
    let playerState: SpotifyPlayerState
    let onPlayPause: () -> Void
    let onPrevious: () -> Void
    let onNext: () -> Void

    private var progress: Double {
        guard playerState.durationMs > 0 else { return 0 }
        return Double(playerState.positionMs) / Double(playerState.durationMs)
    }

    var body: some View {
        HairlineCard {
            VStack(spacing: 16) {
                // Album art
                if let artworkURL = playerState.artworkURL {
                    RemoteStorageImageView(urlString: artworkURL.absoluteString) {
                        artworkPlaceholder
                    }
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    artworkPlaceholder
                        .aspectRatio(1, contentMode: .fit)
                }

                // Track info
                VStack(spacing: 4) {
                    Text(playerState.trackName)
                        .font(MomentsStyle.systemMedium(16))
                        .foregroundColor(MomentsStyle.primaryText)
                        .lineLimit(1)

                    Text(playerState.artistName)
                        .font(MomentsStyle.systemLight(13))
                        .foregroundColor(MomentsStyle.secondaryText)
                        .lineLimit(1)
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
                        Text(formatDuration(playerState.positionMs))
                            .font(.system(size: 10, weight: .light))
                            .foregroundColor(MomentsStyle.secondaryText)

                        Spacer()

                        Text(formatDuration(playerState.durationMs))
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

                    Button(action: onPlayPause) {
                        Image(systemName: playerState.isPaused ? "play.circle.fill" : "pause.circle.fill")
                            .font(.system(size: 40, weight: .light))
                            .foregroundColor(MomentsStyle.primaryText)
                    }

                    Button(action: onNext) {
                        Image(systemName: "forward.end")
                            .font(.system(size: 18, weight: .light))
                            .foregroundColor(MomentsStyle.primaryText)
                    }
                }
            }
        }
    }

    private var artworkPlaceholder: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(MomentsStyle.surfaceSecondary)
            .overlay(
                Image(systemName: "music.note")
                    .font(.system(size: 32, weight: .light))
                    .foregroundColor(MomentsStyle.inactive)
            )
    }
}

// MARK: - Playlist Row

struct PlaylistRow: View {
    let playlist: SpotifyPlaylistItem

    var body: some View {
        HStack(spacing: 14) {
            // Artwork
            RemoteStorageImageView(urlString: playlist.artworkURL?.absoluteString) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(MomentsStyle.surfaceSecondary)
                    .overlay(
                        Image(systemName: "music.note.list")
                            .font(.system(size: 16, weight: .light))
                            .foregroundColor(MomentsStyle.inactive)
                    )
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 6))

            VStack(alignment: .leading, spacing: 3) {
                Text(playlist.name)
                    .font(MomentsStyle.systemMedium(15))
                    .foregroundColor(MomentsStyle.primaryText)

                if let description = playlist.description, !description.isEmpty {
                    Text(description)
                        .font(MomentsStyle.systemLight(12))
                        .foregroundColor(MomentsStyle.secondaryText)
                        .lineLimit(1)
                }

                Text("\(playlist.trackCount) songs")
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

#Preview {
    NavigationStack {
        MusicView()
            .environment(MusicViewModel())
    }
}
