import SwiftUI

struct CuratedPlaylistDetailView: View {
    @Environment(MusicViewModel.self) private var musicViewModel
    @Environment(AppLanguage.self) private var appLanguage
    let playlist: CuratedPlaylist

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Playlist header
                VStack(spacing: 16) {
                    RemoteStorageImageView(urlString: musicViewModel.coverURL(for: playlist.id)) {
                        artworkPlaceholder
                    }
                    .frame(width: 220, height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.15), radius: 12, y: 6)

                    Text(playlist.name)
                        .font(MomentsStyle.georgiaItalic(24))
                        .foregroundColor(MomentsStyle.primaryText)

                    Text(playlist.subtitle)
                        .font(MomentsStyle.systemLight(14))
                        .foregroundColor(MomentsStyle.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    PillTag(label: playlist.mood.capitalized)
                        .padding(.top, 2)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 16)
                .padding(.bottom, 28)

                // Action buttons
                actionButtons
                    .padding(.horizontal, 40)
                    .padding(.bottom, 32)

                // Now Playing section — shows when music is playing
                if let state = musicViewModel.currentPlayerState {
                    nowPlayingSection(state: state)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                }

                // Open in Spotify link
                if let webURL = playlist.spotifyURL {
                    Button {
                        UIApplication.shared.open(webURL)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 10, weight: .light))
                            Text(Strings.musicViewInSpotify)
                                .font(.system(size: 10, weight: .light))
                                .tracking(2)
                        }
                        .foregroundColor(MomentsStyle.secondaryText)
                    }
                    .padding(.bottom, 32)
                }
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

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Play button
            Button {
                if musicViewModel.isConnected {
                    musicViewModel.play(uri: playlist.spotifyURI)
                } else {
                    musicViewModel.authorize()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 10))
                    Text(musicViewModel.isConnected ? Strings.musicPlay : Strings.musicConnectToPlayButton)
                        .font(.system(size: 10, weight: .light))
                        .tracking(3)
                }
                .foregroundColor(MomentsStyle.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(MomentsStyle.primaryText)
                .clipShape(Capsule())
            }

            // Shuffle button
            if musicViewModel.isConnected {
                Button {
                    musicViewModel.play(uri: playlist.spotifyURI)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "shuffle")
                            .font(.system(size: 10))
                        Text(Strings.musicShuffle)
                            .font(.system(size: 10, weight: .light))
                            .tracking(3)
                    }
                    .foregroundColor(MomentsStyle.primaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .overlay(
                        Capsule()
                            .stroke(MomentsStyle.border, lineWidth: 0.5)
                    )
                }
            }
        }
    }

    // MARK: - Now Playing

    private func nowPlayingSection(state: SpotifyPlayerState) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(Strings.musicNowPlaying)
                .font(.system(size: 10, weight: .light))
                .tracking(3)
                .foregroundColor(MomentsStyle.secondaryText)

            NowPlayingCard(
                playerState: state,
                onPlayPause: { musicViewModel.togglePlayback() },
                onPrevious: { musicViewModel.skipPrevious() },
                onNext: { musicViewModel.skipNext() }
            )
        }
    }

    // MARK: - Helpers

    private var artworkPlaceholder: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(MomentsStyle.surfaceSecondary)
            .frame(width: 220, height: 220)
            .overlay(
                Image(systemName: "music.note")
                    .font(.system(size: 36, weight: .light))
                    .foregroundColor(MomentsStyle.inactive)
            )
    }
}

#Preview {
    NavigationStack {
        CuratedPlaylistDetailView(playlist: CuratedPlaylists.all[0])
            .environment(MusicViewModel())
    }
}
