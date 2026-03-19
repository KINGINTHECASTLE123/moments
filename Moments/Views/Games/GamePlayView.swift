import SwiftUI

struct GamePlayView: View {
    let game: Game
    @State private var currentIndex = 0
    @State private var prompts: [GamePrompt] = []

    @Environment(\.dismiss) private var dismiss
    @Environment(AppLanguage.self) private var appLanguage

    private var isLastCard: Bool {
        currentIndex >= prompts.count - 1
    }

    private var instructionText: String {
        GameStrings.instruction(for: game.number)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Card counter
            HStack(spacing: 0) {
                Text("\(currentIndex + 1)")
                    .contentTransition(.numericText())
                Text(" \(Strings.gamesOf) \(prompts.count)")
            }
            .font(MomentsStyle.systemLight(13))
            .foregroundColor(MomentsStyle.secondaryText)
            .animation(.easeInOut(duration: 0.2), value: currentIndex)
            .padding(.top, 16)
            .padding(.bottom, 24)

            Spacer()

            // Swipeable card stack
            if !prompts.isEmpty {
                let isWYR = prompts[currentIndex].optionA != nil
                SwipeableCardStack(
                    totalCount: prompts.count,
                    currentIndex: $currentIndex,
                    maxVisible: isWYR ? 1 : 3
                ) { index in
                    let prompt = prompts[index]
                    if prompt.optionA != nil {
                        WouldYouRatherCard(prompt: prompt)
                    } else {
                        StandardPromptCard(prompt: prompt, gameName: game.localizedName)
                    }
                }
            }

            // Instruction text
            if !instructionText.isEmpty {
                Text(instructionText)
                    .font(MomentsStyle.systemLight(12))
                    .foregroundColor(MomentsStyle.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
            }

            Spacer()

            // Bottom buttons
            VStack(spacing: 14) {
                Button {
                    if !isLastCard {
                        currentIndex += 1
                    } else {
                        Haptics.success()
                        dismiss()
                    }
                } label: {
                    Text(isLastCard ? Strings.gamesFinish : Strings.gamesNext)
                        .font(.system(size: 10, weight: .light))
                        .tracking(3)
                        .foregroundColor(MomentsStyle.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(MomentsStyle.primaryText)
                        .clipShape(Capsule())
                }

                Button {
                    dismiss()
                } label: {
                    Text(Strings.gamesEndGame)
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
                Text(game.localizedName)
                    .font(MomentsStyle.georgiaItalic(18))
                    .foregroundColor(MomentsStyle.primaryText)
            }
        }
        .onAppear {
            prompts = GameStrings.prompts(for: game.number).shuffled()
        }
    }
}

// MARK: - Standard Prompt Card

private struct StandardPromptCard: View {
    let prompt: GamePrompt
    let gameName: String

    @State private var appeared = false

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
            .frame(maxWidth: .infinity, minHeight: 280)
        }
        .padding(.horizontal, 24)
        .scaleEffect(appeared ? 1.0 : 0.96)
        .opacity(appeared ? 1.0 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }
}

// MARK: - Would You Rather Card

private struct WouldYouRatherCard: View {
    let prompt: GamePrompt
    @Environment(AppLanguage.self) private var appLanguage

    var body: some View {
        VStack(spacing: 10) {
            HairlineCard {
                VStack(spacing: 6) {
                    Text("A")
                        .font(MomentsStyle.georgiaItalic(13))
                        .foregroundColor(MomentsStyle.secondaryText)
                    Text(prompt.optionA ?? "")
                        .font(MomentsStyle.systemLight(17))
                        .foregroundColor(MomentsStyle.primaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(24)
                .frame(maxWidth: .infinity, minHeight: 120)
            }

            Text(Strings.gamesOr)
                .font(MomentsStyle.georgiaItalic(14))
                .foregroundColor(MomentsStyle.secondaryText)

            HairlineCard {
                VStack(spacing: 6) {
                    Text("B")
                        .font(MomentsStyle.georgiaItalic(13))
                        .foregroundColor(MomentsStyle.secondaryText)
                    Text(prompt.optionB ?? "")
                        .font(MomentsStyle.systemLight(17))
                        .foregroundColor(MomentsStyle.primaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(24)
                .frame(maxWidth: .infinity, minHeight: 120)
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
