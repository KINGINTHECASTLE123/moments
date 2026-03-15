import SwiftUI

struct GameDetailView: View {
    let game: Game

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Hero area
                ZStack {
                    RoundedRectangle(cornerRadius: 0)
                        .fill(MomentsStyle.surfaceSecondary)
                        .frame(height: 220)

                    VStack(spacing: 12) {
                        Text("\(game.number)")
                            .font(MomentsStyle.georgiaItalic(56))
                            .foregroundColor(MomentsStyle.border)

                        Image(systemName: gameIcon(for: game.number))
                            .font(.system(size: 28, weight: .light))
                            .foregroundColor(MomentsStyle.inactive)
                    }
                }

                VStack(alignment: .leading, spacing: 24) {
                    // Title section
                    VStack(alignment: .leading, spacing: 8) {
                        Text(game.name)
                            .font(MomentsStyle.georgiaItalic(26))
                            .foregroundColor(MomentsStyle.primaryText)

                        Text(game.description)
                            .font(MomentsStyle.systemLight(14))
                            .foregroundColor(MomentsStyle.secondaryText)

                        HStack(spacing: 6) {
                            PillTag(label: game.tag)
                            PillTag(label: "\(game.promptCount) prompts")
                        }
                        .padding(.top, 4)
                    }

                    // Divider
                    Rectangle()
                        .fill(MomentsStyle.border)
                        .frame(height: 0.5)

                    // How to Play
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How to Play")
                            .font(MomentsStyle.systemMedium(18))
                            .foregroundColor(MomentsStyle.primaryText)

                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(Array(game.rules.enumerated()), id: \.offset) { index, rule in
                                HStack(alignment: .top, spacing: 14) {
                                    Text("\(index + 1)")
                                        .font(MomentsStyle.systemMedium(14))
                                        .foregroundColor(MomentsStyle.secondaryText)
                                        .frame(width: 20, alignment: .center)

                                    Text(rule)
                                        .font(MomentsStyle.systemLight(15))
                                        .foregroundColor(MomentsStyle.primaryText)
                                        .lineSpacing(3)
                                }
                            }
                        }
                    }

                    // Divider
                    Rectangle()
                        .fill(MomentsStyle.border)
                        .frame(height: 0.5)

                    // Start Game button
                    NavigationLink(value: GamePlayDestination(gameNumber: game.number)) {
                        Text("START GAME")
                            .font(.system(size: 10, weight: .light))
                            .tracking(3)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(MomentsStyle.primaryText)
                            .clipShape(Capsule())
                    }
                }
                .padding(24)
            }
        }
        .background(MomentsStyle.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(game.name)
                    .font(MomentsStyle.georgiaItalic(18))
                    .foregroundColor(MomentsStyle.primaryText)
            }
        }
        .navigationDestination(for: GamePlayDestination.self) { _ in
            GamePlayView(game: game)
        }
    }

    private func gameIcon(for number: Int) -> String {
        switch number {
        case 1: return "arrow.left.arrow.right"
        case 2: return "hand.raised"
        case 3: return "theatermasks"
        case 4: return "moon.stars"
        case 5: return "heart"
        case 6: return "flame"
        default: return "dice"
        }
    }
}

#Preview {
    NavigationStack {
        GameDetailView(game: lightGames[0])
    }
}
