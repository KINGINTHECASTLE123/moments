import SwiftUI

struct GamesView: View {
    private let bottomContentInset: CGFloat = 96

    @Environment(AppLanguage.self) private var appLanguage
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    SectionHeader(Strings.gamesTitle, subtitle: Strings.gamesSubtitle)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                        .padding(.bottom, 12)

                    GameSection(title: Strings.gamesLightSocial, games: lightGames)

                    GameSection(title: Strings.gamesDeepPlayful, games: deepGames)

                    Spacer(minLength: bottomContentInset)
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
            .navigationDestination(for: Game.self) { game in
                GameDetailView(game: game)
            }
        }
    }
}

struct GameSection: View {
    let title: String
    let games: [Game]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .light))
                .tracking(3)
                .foregroundColor(MomentsStyle.secondaryText)
                .padding(.horizontal, 24)
                .padding(.top, 28)
                .padding(.bottom, 12)

            VStack(spacing: 0) {
                ForEach(games) { game in
                    NavigationLink(value: game) {
                        GameRow(game: game)
                    }
                    .buttonStyle(.plain)

                    if game.id != games.last?.id {
                        Rectangle()
                            .frame(height: 0.5)
                            .foregroundColor(MomentsStyle.border)
                            .padding(.leading, 60)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 4)
            .background(MomentsStyle.cardBackground)
        }
    }
}

struct GameRow: View {
    let game: Game
    @Environment(AppLanguage.self) private var appLanguage

    var body: some View {
        HStack(spacing: 16) {
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

            Spacer(minLength: 8)

            PillTag(label: game.localizedTag)
                .fixedSize()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .light))
                .foregroundColor(MomentsStyle.inactive)
        }
        .padding(.vertical, 14)
    }
}

#Preview {
    NavigationStack {
        GamesView()
            .environment(AppLanguage.shared)
    }
}
