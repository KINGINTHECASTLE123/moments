import SwiftUI

struct GamesView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                SectionHeader("Games", subtitle: "Break the ice, spark the night")
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 28)

                GameSection(title: "Light & Social", games: lightGames)

                GameSection(title: "Deep & Playful", games: deepGames)
                    .padding(.top, 28)

                Spacer(minLength: 32)
            }
        }
        .background(MomentsStyle.background)
        .navigationDestination(for: Game.self) { game in
            GameDetailView(game: game)
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
                .padding(.bottom, 14)

            ForEach(games) { game in
                NavigationLink(value: game) {
                    GameRow(game: game)
                }
                .buttonStyle(.plain)

                if game.id != games.last?.id {
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(MomentsStyle.border)
                        .padding(.horizontal, 24)
                }
            }
        }
    }
}

struct GameRow: View {
    let game: Game

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
                Text(game.name)
                    .font(MomentsStyle.systemMedium(15))
                    .foregroundColor(MomentsStyle.primaryText)

                Text(game.description)
                    .font(MomentsStyle.systemLight(13))
                    .foregroundColor(MomentsStyle.secondaryText)
            }

            Spacer()

            PillTag(label: game.tag)

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
        GamesView()
    }
}
