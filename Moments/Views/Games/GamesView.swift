import SwiftUI

struct Game: Identifiable {
    let id = UUID()
    let number: Int
    let name: String
    let description: String
    let tag: String
}

private let lightGames: [Game] = [
    Game(number: 1, name: "Would You Rather", description: "Classic dilemmas that spark debate", tag: "Icebreaker"),
    Game(number: 2, name: "Heads Up", description: "Guess the word on your forehead", tag: "Party"),
    Game(number: 3, name: "Charades", description: "Act it out, no words allowed", tag: "Classic"),
]

private let deepGames: [Game] = [
    Game(number: 4, name: "Late Night Conversations", description: "Questions that go deeper", tag: "Intimate"),
    Game(number: 5, name: "Flirty & Fun", description: "Playful prompts for bold moments", tag: "Bold"),
    Game(number: 6, name: "High Stakes", description: "Dares and challenges with consequences", tag: "Daring"),
]

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
                GameRow(game: game)

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
            Text("\(game.number)")
                .font(MomentsStyle.georgiaItalic(24))
                .foregroundColor(MomentsStyle.border)
                .frame(width: 32, alignment: .center)

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
    GamesView()
}
