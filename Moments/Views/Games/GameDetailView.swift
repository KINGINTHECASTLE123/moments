import SwiftUI

struct GameDetailView: View {
    let game: Game
    @Environment(AppLanguage.self) private var appLanguage

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Hero area
                ParallaxHeader(height: 220, coordinateSpace: "scroll") {
                    ZStack {
                        MomentsStyle.surfaceSecondary

                        VStack(spacing: 16) {
                            Image(systemName: game.icon)
                                .font(.system(size: 48, weight: .light))
                                .foregroundColor(MomentsStyle.primaryText)

                            Text(game.localizedTag.uppercased())
                                .font(.system(size: 10, weight: .light))
                                .tracking(3)
                                .foregroundColor(MomentsStyle.secondaryText)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 24) {
                    // Title section
                    VStack(alignment: .leading, spacing: 8) {
                        Text(game.localizedName)
                            .font(MomentsStyle.georgiaItalic(26))
                            .foregroundColor(MomentsStyle.primaryText)

                        Text(game.localizedDescription)
                            .font(MomentsStyle.systemLight(14))
                            .foregroundColor(MomentsStyle.secondaryText)

                        HStack(spacing: 6) {
                            PillTag(label: game.localizedTag)
                            PillTag(label: "\(game.promptCount) \(Strings.gamesPrompts)")
                        }
                        .padding(.top, 4)
                    }

                    // Divider
                    Rectangle()
                        .fill(MomentsStyle.border)
                        .frame(height: 0.5)

                    // How to Play
                    VStack(alignment: .leading, spacing: 12) {
                        Text(Strings.gamesHowToPlay)
                            .font(MomentsStyle.systemMedium(18))
                            .foregroundColor(MomentsStyle.primaryText)

                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(Array(game.localizedRules.enumerated()), id: \.offset) { index, rule in
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
                        Text(Strings.gamesStartGame)
                            .font(.system(size: 10, weight: .light))
                            .tracking(3)
                            .foregroundColor(MomentsStyle.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(MomentsStyle.primaryText)
                            .clipShape(Capsule())
                    }
                }
                .padding(24)
            }
        }
        .coordinateSpace(name: "scroll")
        .background(MomentsStyle.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(game.localizedName)
                    .font(MomentsStyle.georgiaItalic(18))
                    .foregroundColor(MomentsStyle.primaryText)
            }
        }
        .navigationDestination(for: GamePlayDestination.self) { _ in
            GamePlayView(game: game)
        }
    }

}

#Preview {
    NavigationStack {
        GameDetailView(game: lightGames[0])
    }
}
