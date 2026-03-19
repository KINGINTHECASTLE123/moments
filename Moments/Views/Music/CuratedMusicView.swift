import SwiftUI
import UIKit

struct CuratedMusicView: View {
    @Environment(MusicViewModel.self) private var musicViewModel
    @Environment(AppLanguage.self) private var appLanguage
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMood: String = "all"

    private let moods = ["all", "intimate", "energetic", "chill"]

    private var featuredPlaylist: CuratedPlaylist {
        let hour = Calendar.current.component(.hour, from: Date())
        return CuratedPlaylists.featured(for: hour)
    }

    private var filteredPlaylists: [CuratedPlaylist] {
        CuratedPlaylists.filtered(by: selectedMood)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                // Header
                SectionHeader(Strings.musicTitle, subtitle: Strings.musicSubtitle)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 24)

                // Now Playing (if Spotify is playing)
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

                // Tonight's Pick
                tonightsPickSection(featuredPlaylist)

                // Connect prompt (subtle, only when not connected and nothing playing)
                if !musicViewModel.isConnected && musicViewModel.currentPlayerState == nil {
                    connectPrompt
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                }

                // Browse by Mood
                moodFilterSection

                // All Playlists
                playlistListSection

                Spacer(minLength: 32)
            }
            }
            .background(MomentsStyle.background)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(MomentsStyle.primaryText)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel(Strings.tabHome)
                }
            }
            .navigationDestination(for: CuratedPlaylist.self) { playlist in
                CuratedPlaylistDetailView(playlist: playlist)
            }
            .task {
                await musicViewModel.fetchPlaylistCovers()
            }
            .refreshable {
                await musicViewModel.fetchPlaylistCovers()
            }
        }
    }

    // MARK: - Tonight's Pick

    @ViewBuilder
    private func tonightsPickSection(_ playlist: CuratedPlaylist) -> some View {
        Text(Strings.musicTonightsPick)
            .font(.system(size: 10, weight: .light))
            .tracking(3)
            .foregroundColor(MomentsStyle.secondaryText)
            .padding(.horizontal, 24)
            .padding(.bottom, 14)

        HairlineCard {
            VStack(alignment: .leading, spacing: 0) {
                NavigationLink(value: playlist) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Cover art
                        RemoteStorageImageView(urlString: musicViewModel.coverURL(for: playlist.id)) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(MomentsStyle.surfaceSecondary)
                                .frame(height: 200)
                                .overlay(
                                    Image(systemName: "music.note")
                                        .font(.system(size: 36, weight: .light))
                                        .foregroundColor(MomentsStyle.inactive)
                                )
                        }
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.bottom, 16)

                        // Playlist name
                        Text(playlist.name)
                            .font(MomentsStyle.georgiaItalic(22))
                            .foregroundColor(MomentsStyle.primaryText)
                            .padding(.bottom, 4)

                        // Subtitle
                        Text(playlist.subtitle)
                            .font(MomentsStyle.systemLight(14))
                            .foregroundColor(MomentsStyle.secondaryText)
                            .padding(.bottom, 16)
                    }
                }
                .buttonStyle(.plain)

                // Play button (direct play action)
                PlayButton(playlist: playlist)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 28)
    }

    // MARK: - Connect Prompt

    private var connectPrompt: some View {
        HStack(spacing: 10) {
            Text(Strings.musicConnectToPlay)
                .font(MomentsStyle.systemLight(12))
                .foregroundColor(MomentsStyle.secondaryText)

            Spacer()

            Button {
                musicViewModel.authorize()
            } label: {
                Text(Strings.musicConnect)
                    .font(.system(size: 9, weight: .light))
                    .tracking(2)
                    .foregroundColor(MomentsStyle.primaryText)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .overlay(
                        Capsule()
                            .stroke(MomentsStyle.border, lineWidth: 0.5)
                    )
            }
        }
    }

    // MARK: - Mood Filter

    private var moodFilterSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(Strings.musicBrowseByMood)
                .font(.system(size: 10, weight: .light))
                .tracking(3)
                .foregroundColor(MomentsStyle.secondaryText)
                .padding(.horizontal, 24)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(moods, id: \.self) { mood in
                        Button {
                            Haptics.select()
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedMood = mood
                            }
                        } label: {
                            PillTag(
                                label: moodLabel(for: mood),
                                filled: selectedMood == mood
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .padding(.bottom, 24)
    }

    // MARK: - Mood Label

    private func moodLabel(for mood: String) -> String {
        switch mood {
        case "all": return Strings.musicMoodAll
        case "intimate": return Strings.musicMoodIntimate
        case "energetic": return Strings.musicMoodEnergetic
        case "chill": return Strings.musicMoodChill
        default: return mood.capitalized
        }
    }

    // MARK: - Playlist List

    private var playlistListSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(Strings.musicAllPlaylists)
                .font(.system(size: 10, weight: .light))
                .tracking(3)
                .foregroundColor(MomentsStyle.secondaryText)
                .padding(.horizontal, 24)
                .padding(.bottom, 14)

            ForEach(filteredPlaylists) { playlist in
                NavigationLink(value: playlist) {
                    CuratedPlaylistRow(playlist: playlist, coverURL: musicViewModel.coverURL(for: playlist.id))
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
    }

}

// MARK: - Play Button

private struct PlayButton: View {
    let playlist: CuratedPlaylist
    @Environment(MusicViewModel.self) private var musicViewModel
    @Environment(AppLanguage.self) private var appLanguage

    private var isSpotifyInstalled: Bool {
        guard let url = URL(string: "spotify://") else { return false }
        return UIApplication.shared.canOpenURL(url)
    }

    var body: some View {
        Button {
            if isSpotifyInstalled {
                if musicViewModel.isConnected {
                    musicViewModel.play(uri: playlist.spotifyURI)
                } else {
                    musicViewModel.authorize()
                }
            } else {
                if let webURL = playlist.spotifyURL {
                    UIApplication.shared.open(webURL)
                }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "play.fill")
                    .font(.system(size: 10))
                Text(Strings.musicPlay)
                    .font(.system(size: 10, weight: .light))
                    .tracking(3)
            }
            .foregroundColor(MomentsStyle.background)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(MomentsStyle.primaryText)
            .clipShape(Capsule())
        }
    }
}

// MARK: - Curated Playlist Row

private struct CuratedPlaylistRow: View {
    let playlist: CuratedPlaylist
    let coverURL: String?

    var body: some View {
        HStack(spacing: 14) {
            // Artwork
            RemoteStorageImageView(urlString: coverURL) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(MomentsStyle.surfaceSecondary)
                    .overlay(
                        Image(systemName: "music.note")
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

                Text(playlist.subtitle)
                    .font(MomentsStyle.systemLight(13))
                    .foregroundColor(MomentsStyle.secondaryText)
                    .lineLimit(1)
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

#Preview {
    NavigationStack {
        CuratedMusicView()
            .environment(MusicViewModel())
    }
}
