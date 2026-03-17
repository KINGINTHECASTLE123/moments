import SwiftUI

struct GamePlayView: View {
    let game: Game
    @State private var currentIndex = 0
    @State private var prompts: [GamePrompt] = []
    @Environment(\.dismiss) private var dismiss

    private var isLastCard: Bool {
        currentIndex >= prompts.count - 1
    }

    private var instructionText: String {
        switch game.number {
        case 1: "Read both options aloud. Everyone picks a side."
        case 2: "Hold phone to your forehead. Friends describe the word."
        case 3: "Act it out. No talking, no pointing."
        case 4: "Read aloud. Everyone takes a turn answering."
        case 5: "Read the prompt. Be bold."
        case 6: "Complete the dare — or face the penalty."
        default: ""
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Card counter
            HStack(spacing: 0) {
                Text("\(currentIndex + 1)")
                    .contentTransition(.numericText())
                Text(" of \(prompts.count)")
            }
            .font(MomentsStyle.systemLight(13))
            .foregroundColor(MomentsStyle.secondaryText)
            .animation(.easeInOut(duration: 0.2), value: currentIndex)
            .padding(.top, 16)
            .padding(.bottom, 24)

            Spacer()

            // Swipeable card stack
            if !prompts.isEmpty {
                SwipeableCardStack(totalCount: prompts.count, currentIndex: $currentIndex) { index in
                    let prompt = prompts[index]
                    if prompt.optionA != nil {
                        WouldYouRatherCard(prompt: prompt, appearID: currentIndex)
                    } else {
                        StandardPromptCard(prompt: prompt, gameName: game.name)
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
                    Text(isLastCard ? "FINISH" : "NEXT")
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
    let appearID: Int

    @State private var showOptionA = false
    @State private var showOr = false
    @State private var showOptionB = false

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
            .offset(x: showOptionA ? 0 : -10)
            .opacity(showOptionA ? 1 : 0)

            Text("or")
                .font(MomentsStyle.georgiaItalic(16))
                .foregroundColor(MomentsStyle.secondaryText)
                .opacity(showOr ? 1 : 0)

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
            .offset(x: showOptionB ? 0 : 10)
            .opacity(showOptionB ? 1 : 0)
        }
        .padding(.horizontal, 24)
        .onChange(of: appearID) { _, _ in
            resetAndAnimate()
        }
        .onAppear {
            resetAndAnimate()
        }
    }

    private func resetAndAnimate() {
        showOptionA = false
        showOr = false
        showOptionB = false

        withAnimation(.easeOut(duration: 0.3).delay(0.1)) {
            showOptionA = true
        }
        withAnimation(.easeOut(duration: 0.3).delay(0.25)) {
            showOr = true
        }
        withAnimation(.easeOut(duration: 0.3).delay(0.35)) {
            showOptionB = true
        }
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
