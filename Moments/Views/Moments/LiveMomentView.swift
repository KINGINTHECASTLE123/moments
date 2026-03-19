import SwiftUI

struct LiveMomentView: View {
    @Environment(MomentPlannerViewModel.self) private var planner
    @Environment(MusicViewModel.self) private var musicViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(AppLanguage.self) private var appLanguage
    @State private var showEndConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(planner.currentPlan?.title ?? "Your Moment")
                            .font(MomentsStyle.georgiaItalic(26))
                            .foregroundColor(MomentsStyle.primaryText)

                        if let vibe = planner.currentPlan?.vibe, vibe != "custom" {
                            PillTag(label: vibe.replacingOccurrences(of: "-", with: " "))
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 28)

                // Now Playing
                nowPlayingSection
                    .padding(.bottom, 28)

                // Tonight's Menu
                menuSection
                    .padding(.bottom, 28)

                // Games
                gamesSection
                    .padding(.bottom, 40)

                // End Moment
                Button {
                    showEndConfirmation = true
                } label: {
                    Text(Strings.liveMomentEndMoment)
                        .font(.system(size: 11, weight: .light))
                        .tracking(2)
                        .foregroundColor(.red.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(MomentsStyle.border, lineWidth: 1)
                        )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .background(MomentsStyle.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(Strings.liveMomentLive)
                    .font(MomentsStyle.georgiaItalic(18))
                    .foregroundColor(MomentsStyle.primaryText)
            }
        }
        .navigationDestination(for: Game.self) { game in
            GameDetailView(game: game)
        }
        .confirmationDialog(
            Strings.liveMomentEndAlertTitle,
            isPresented: $showEndConfirmation,
            titleVisibility: .visible
        ) {
            Button(Strings.liveMomentEndAlertConfirm, role: .destructive) {
                planner.endMoment()
                dismiss()
            }
            Button(Strings.liveMomentEndAlertCancel, role: .cancel) {}
        }

    }

    // MARK: - Now Playing

    @ViewBuilder
    private var nowPlayingSection: some View {
        Text(Strings.liveMomentNowPlaying)
            .font(.system(size: 10, weight: .light))
            .tracking(3)
            .foregroundColor(MomentsStyle.secondaryText)
            .padding(.horizontal, 24)
            .padding(.bottom, 14)

        if let state = musicViewModel.currentPlayerState {
            CompactNowPlayingCard(
                playerState: state,
                onPlayPause: { musicViewModel.togglePlayback() },
                onNext: { musicViewModel.skipNext() }
            )
            .padding(.horizontal, 24)
        } else if let playlistId = planner.currentPlan?.playlistId {
            let playlistName: String = {
                if let playlist = CuratedPlaylists.all.first(where: { $0.id == playlistId }) {
                    return playlist.name
                }
                return playlistId.replacingOccurrences(of: "-", with: " ").capitalized
            }()

            HairlineCard {
                HStack(spacing: 14) {
                    Circle()
                        .fill(MomentsStyle.surfaceSecondary)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "music.note")
                                .font(.system(size: 18, weight: .light))
                                .foregroundColor(MomentsStyle.primaryText)
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text(playlistName)
                            .font(MomentsStyle.systemMedium(15))
                            .foregroundColor(MomentsStyle.primaryText)

                        Text(Strings.liveMomentTapToPlay)
                            .font(MomentsStyle.systemLight(12))
                            .foregroundColor(MomentsStyle.secondaryText)
                    }

                    Spacer()

                    PlayOnSpotifyButton(playlistId: playlistId)
                }
            }
            .padding(.horizontal, 24)
        } else {
            HairlineCard {
                HStack(spacing: 14) {
                    Image(systemName: "music.note")
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(MomentsStyle.inactive)

                    Text(Strings.liveMomentNoPlaylist)
                        .font(MomentsStyle.systemLight(14))
                        .foregroundColor(MomentsStyle.secondaryText)

                    Spacer()
                }
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Menu

    @ViewBuilder
    private var menuSection: some View {
        if let dishIds = planner.currentPlan?.dishIds, !dishIds.isEmpty {
            Text(Strings.liveMomentTonightsMenu)
                .font(.system(size: 10, weight: .light))
                .tracking(3)
                .foregroundColor(MomentsStyle.secondaryText)
                .padding(.horizontal, 24)
                .padding(.bottom, 14)

            VStack(spacing: 0) {
                ForEach(Array(dishIds.enumerated()), id: \.element) { index, dishId in
                    HStack(spacing: 14) {
                        Circle()
                            .fill(MomentsStyle.surfaceSecondary)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Image(systemName: "fork.knife")
                                    .font(.system(size: 14, weight: .light))
                                    .foregroundColor(MomentsStyle.primaryText)
                            )

                        Text(dishId.replacingOccurrences(of: "-", with: " ").capitalized)
                            .font(MomentsStyle.systemMedium(15))
                            .foregroundColor(MomentsStyle.primaryText)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .light))
                            .foregroundColor(MomentsStyle.inactive)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)

                    if index < dishIds.count - 1 {
                        Rectangle()
                            .frame(height: 0.5)
                            .foregroundColor(MomentsStyle.border)
                            .padding(.horizontal, 24)
                    }
                }
            }
        }
    }

    // MARK: - Games

    @ViewBuilder
    private var gamesSection: some View {
        if let gameNumbers = planner.currentPlan?.gameNumbers, !gameNumbers.isEmpty {
            Text(Strings.liveMomentGames)
                .font(.system(size: 10, weight: .light))
                .tracking(3)
                .foregroundColor(MomentsStyle.secondaryText)
                .padding(.horizontal, 24)
                .padding(.bottom, 14)

            VStack(spacing: 0) {
                ForEach(Array(gameNumbers.enumerated()), id: \.element) { index, number in
                    let game = gameByNumber(number)

                    if let game {
                        NavigationLink(value: game) {
                            HStack(spacing: 14) {
                                Circle()
                                    .fill(MomentsStyle.surfaceSecondary)
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Image(systemName: game.icon)
                                            .font(.system(size: 18, weight: .light))
                                            .foregroundColor(MomentsStyle.primaryText)
                                    )

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(game.localizedName)
                                        .font(MomentsStyle.systemMedium(15))
                                        .foregroundColor(MomentsStyle.primaryText)

                                    Text(game.localizedDescription)
                                        .font(MomentsStyle.systemLight(13))
                                        .foregroundColor(MomentsStyle.secondaryText)
                                }

                                Spacer()

                                PillTag(label: game.localizedTag)

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .light))
                                    .foregroundColor(MomentsStyle.inactive)
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                        }
                        .buttonStyle(.plain)
                    }

                    if index < gameNumbers.count - 1 {
                        Rectangle()
                            .frame(height: 0.5)
                            .foregroundColor(MomentsStyle.border)
                            .padding(.horizontal, 24)
                    }
                }
            }
        }
    }

}

// MARK: - Compact Now Playing Card

private struct CompactNowPlayingCard: View {
    let playerState: SpotifyPlayerState
    let onPlayPause: () -> Void
    let onNext: () -> Void

    var body: some View {
        HairlineCard {
            HStack(spacing: 14) {
                // Artwork
                if let artworkURL = playerState.artworkURL {
                    RemoteStorageImageView(urlString: artworkURL.absoluteString) {
                        artworkPlaceholder
                    }
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                } else {
                    artworkPlaceholder
                        .frame(width: 48, height: 48)
                }

                // Track info
                VStack(alignment: .leading, spacing: 2) {
                    Text(playerState.trackName)
                        .font(MomentsStyle.systemMedium(14))
                        .foregroundColor(MomentsStyle.primaryText)
                        .lineLimit(1)

                    Text(playerState.artistName)
                        .font(MomentsStyle.systemLight(12))
                        .foregroundColor(MomentsStyle.secondaryText)
                        .lineLimit(1)
                }

                Spacer()

                // Controls
                HStack(spacing: 20) {
                    Button(action: onPlayPause) {
                        Image(systemName: playerState.isPaused ? "play.fill" : "pause.fill")
                            .font(.system(size: 18, weight: .light))
                            .foregroundColor(MomentsStyle.primaryText)
                    }

                    Button(action: onNext) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(MomentsStyle.primaryText)
                    }
                }
            }
        }
    }

    private var artworkPlaceholder: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(MomentsStyle.surfaceSecondary)
            .overlay(
                Image(systemName: "music.note")
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(MomentsStyle.inactive)
            )
    }
}

// MARK: - Play on Spotify Button

private struct PlayOnSpotifyButton: View {
    let playlistId: String
    @Environment(MusicViewModel.self) private var musicViewModel

    var body: some View {
        Button {
            if let playlist = CuratedPlaylists.all.first(where: { $0.id == playlistId }) {
                if musicViewModel.isConnected {
                    musicViewModel.play(uri: playlist.spotifyURI)
                } else {
                    musicViewModel.authorize()
                }
            } else if let url = URL(string: "https://open.spotify.com/playlist/\(playlistId)") {
                UIApplication.shared.open(url)
            }
        } label: {
            Image(systemName: "play.fill")
                .font(.system(size: 12))
                .foregroundColor(MomentsStyle.background)
                .frame(width: 36, height: 36)
                .background(MomentsStyle.primaryText)
                .clipShape(Circle())
        }
    }
}

// MARK: - Helpers

private func gameByNumber(_ number: Int) -> Game? {
    (lightGames + deepGames).first(where: { $0.number == number })
}

#Preview {
    let vm = MomentPlannerViewModel()
    vm.createFromTemplate(momentTemplates[0])
    vm.startMoment()

    return NavigationStack {
        LiveMomentView()
            .environment(vm)
            .environment(MusicViewModel())
    }
}
