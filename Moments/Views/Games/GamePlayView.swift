import SwiftUI

struct GamePlayView: View {
    let game: Game
    @State private var currentIndex = 0
    @State private var prompts: [GamePrompt] = []
    @Environment(\.dismiss) private var dismiss

    private var currentPrompt: GamePrompt? {
        guard currentIndex < prompts.count else { return nil }
        return prompts[currentIndex]
    }

    private var isLastCard: Bool {
        currentIndex >= prompts.count - 1
    }

    var body: some View {
        VStack(spacing: 0) {
            // Card counter
            Text("\(currentIndex + 1) of \(prompts.count)")
                .font(MomentsStyle.systemLight(13))
                .foregroundColor(MomentsStyle.secondaryText)
                .padding(.top, 16)
                .padding(.bottom, 24)

            Spacer()

            // Prompt card
            if let prompt = currentPrompt {
                if prompt.optionA != nil {
                    WouldYouRatherCard(prompt: prompt)
                } else {
                    StandardPromptCard(prompt: prompt, gameName: game.name)
                }
            }

            Spacer()

            // Bottom buttons
            VStack(spacing: 14) {
                Button {
                    if !isLastCard {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            currentIndex += 1
                        }
                    } else {
                        dismiss()
                    }
                } label: {
                    Text(isLastCard ? "FINISH" : "NEXT")
                        .font(.system(size: 10, weight: .light))
                        .tracking(3)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(MomentsStyle.primaryText)
                        .clipShape(Capsule())
                }

                Button {
                    dismiss()
                } label: {
                    Text("END GAME")
                        .font(.system(size: 10, weight: .light))
                        .tracking(3)
                        .foregroundColor(MomentsStyle.secondaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .overlay(
                            Capsule()
                                .stroke(MomentsStyle.border, lineWidth: 0.5)
                        )
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(MomentsStyle.background)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(MomentsStyle.primaryText)
                }
            }
            ToolbarItem(placement: .principal) {
                Text(game.name)
                    .font(MomentsStyle.georgiaItalic(18))
                    .foregroundColor(MomentsStyle.primaryText)
            }
        }
        .onAppear {
            prompts = (gamePrompts[game.number] ?? []).shuffled()
        }
    }
}

// MARK: - Standard Prompt Card

private struct StandardPromptCard: View {
    let prompt: GamePrompt
    let gameName: String

    var body: some View {
        HairlineCard {
            VStack(spacing: 20) {
                Text(gameName.uppercased())
                    .font(.system(size: 9, weight: .light))
                    .tracking(3)
                    .foregroundColor(MomentsStyle.secondaryText)

                Text(prompt.text)
                    .font(MomentsStyle.georgiaItalic(24))
                    .foregroundColor(MomentsStyle.primaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Would You Rather Card

private struct WouldYouRatherCard: View {
    let prompt: GamePrompt

    var body: some View {
        VStack(spacing: 16) {
            HairlineCard {
                VStack(spacing: 12) {
                    Text("A")
                        .font(MomentsStyle.georgiaItalic(18))
                        .foregroundColor(MomentsStyle.secondaryText)

                    Text(prompt.optionA ?? "")
                        .font(MomentsStyle.systemLight(16))
                        .foregroundColor(MomentsStyle.primaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(24)
                .frame(maxWidth: .infinity)
            }

            Text("or")
                .font(MomentsStyle.georgiaItalic(16))
                .foregroundColor(MomentsStyle.secondaryText)

            HairlineCard {
                VStack(spacing: 12) {
                    Text("B")
                        .font(MomentsStyle.georgiaItalic(18))
                        .foregroundColor(MomentsStyle.secondaryText)

                    Text(prompt.optionB ?? "")
                        .font(MomentsStyle.systemLight(16))
                        .foregroundColor(MomentsStyle.primaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(24)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 24)
    }
}

#Preview("Would You Rather") {
    NavigationStack {
        GamePlayView(game: lightGames[0])
    }
}

#Preview("Standard Game") {
    NavigationStack {
        GamePlayView(game: deepGames[0])
    }
}
