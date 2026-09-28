import SwiftUI
import Combine

struct GamePlayView: View {
    let game: Game
    @State private var currentIndex = 0
    @State private var prompts: [GamePrompt] = []
    @State private var advanceTrigger = 0
    @State private var showCompletion = false

    // Timer state — only active when game.hasTimer is true
    @State private var timeRemaining: Int = 0
    @State private var timerRunning = false
    @State private var timerExpired = false

    @Environment(\.dismiss) private var dismiss
    @Environment(AppLanguage.self) private var appLanguage

    private var isLastCard: Bool {
        currentIndex >= prompts.count - 1
    }

    private func resetTimer() {
        guard game.hasTimer else { return }
        timeRemaining = game.timerSeconds
        timerExpired = false
        timerRunning = false
    }

    private var instructionText: String {
        GameStrings.instruction(for: game.number)
    }

    private var gameAccentColor: Color {
        GamePersonality.identity(for: game.number).accentColor
    }

    var body: some View {
        ZStack {
        VStack(spacing: 0) {
            // Progress indicator
            VStack(spacing: 8) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(MomentsStyle.border)
                            .frame(height: 1.5)

                        Rectangle()
                            .fill(gameAccentColor.opacity(0.6))
                            .frame(
                                width: prompts.isEmpty ? 0 : geo.size.width * CGFloat(currentIndex + 1) / CGFloat(prompts.count),
                                height: 1.5
                            )
                            .animation(.easeInOut(duration: 0.3), value: currentIndex)
                    }
                }
                .frame(height: 1.5)
                .padding(.horizontal, 24)

                Text("\(currentIndex + 1) / \(prompts.count)")
                    .font(.system(size: 11, weight: .light))
                    .foregroundColor(MomentsStyle.secondaryText)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.2), value: currentIndex)
            }
            .padding(.top, 16)
            .padding(.bottom, 20)

            Spacer()

            // Swipeable card stack
            if !prompts.isEmpty {
                // ── FIX ──────────────────────────────────────────────────
                // maxVisible is derived from game.number (constant for the
                // session) instead of prompts[currentIndex].optionA.
                //
                // The old approach recomputed isWYR on every currentIndex
                // change.  Even though the VALUE never changed mid-game,
                // if it ever DID (mixed prompt types), SwiftUI would see a
                // different maxVisible, recreate SwipeableCardStack, and
                // reset all its @State — killing mid-animation state.
                // ─────────────────────────────────────────────────────────
                SwipeableCardStack(
                    totalCount: prompts.count,
                    currentIndex: $currentIndex,
                    maxVisible: game.number == 1 ? 1 : 3,
                    advanceTrigger: advanceTrigger
                ) { index in
                    let prompt = prompts[index]
                    if prompt.optionA != nil {
                        WouldYouRatherCard(prompt: prompt, game: game)
                    } else if game.number == 3 {
                        CharadesCard(
                            prompt: prompt,
                            game: game,
                            timeRemaining: timeRemaining,
                            timerRunning: timerRunning,
                            timerExpired: timerExpired,
                            onTimerTap: {
                                if timerExpired {
                                    resetTimer()
                                } else {
                                    timerRunning.toggle()
                                    Haptics.select()
                                }
                            }
                        )
                    } else {
                        StandardPromptCard(prompt: prompt, game: game)
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
                        Haptics.select()
                        advanceTrigger += 1
                    } else {
                        Haptics.success()
                        showCompletion = true
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
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
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
            resetTimer()
        }
        .onChange(of: advanceTrigger) {
            resetTimer()
        }
        .onChange(of: currentIndex) {
            // currentIndex also changes on swipe — ensure timer resets
            resetTimer()
        }
        // 1-second tick driving the countdown
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            guard game.hasTimer, timerRunning, timeRemaining > 0 else { return }
            timeRemaining -= 1
            if timeRemaining == 0 {
                timerRunning = false
                timerExpired = true
                Haptics.timerEnd()
            }
        }

        // Completion overlay — slides up over the game content
        if showCompletion {
            GameCompletionView(
                game: game,
                promptCount: prompts.count,
                onPlayAgain: {
                    prompts = GameStrings.prompts(for: game.number).shuffled()
                    currentIndex = 0
                    advanceTrigger = 0
                    showCompletion = false
                },
                onBack: { dismiss() }
            )
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        } // ZStack
        .animation(.easeInOut(duration: 0.35), value: showCompletion)
    }
}

// MARK: - Game Personality

/// Visual identity for each game — color tint and SF symbol icon.
/// Colors stay within the warm neutral palette (never raw primaries).
private enum GamePersonality {
    struct Identity {
        let accentColor: Color
        let icon: String
    }

    static func identity(for gameNumber: Int) -> Identity {
        switch gameNumber {
        case 1: // Would You Rather — cool blue: measured, cerebral
            return Identity(
                accentColor: Color(UIColor { t in
                    t.userInterfaceStyle == .dark
                        ? UIColor(red: 0.55, green: 0.65, blue: 0.85, alpha: 1)
                        : UIColor(red: 0.35, green: 0.48, blue: 0.72, alpha: 1)
                }),
                icon: "arrow.left.arrow.right"
            )
        case 2: // Heads Up — warm amber: energetic, party
            return Identity(
                accentColor: Color(UIColor { t in
                    t.userInterfaceStyle == .dark
                        ? UIColor(red: 0.90, green: 0.68, blue: 0.28, alpha: 1)
                        : UIColor(red: 0.80, green: 0.56, blue: 0.14, alpha: 1)
                }),
                icon: "hand.raised"
            )
        case 3: // Charades — terracotta: playful, physical
            return Identity(
                accentColor: Color(UIColor { t in
                    t.userInterfaceStyle == .dark
                        ? UIColor(red: 0.88, green: 0.52, blue: 0.36, alpha: 1)
                        : UIColor(red: 0.76, green: 0.38, blue: 0.22, alpha: 1)
                }),
                icon: "theatermasks"
            )
        case 4: // Late Night — violet: intimate, introspective
            return Identity(
                accentColor: Color(UIColor { t in
                    t.userInterfaceStyle == .dark
                        ? UIColor(red: 0.60, green: 0.55, blue: 0.85, alpha: 1)
                        : UIColor(red: 0.44, green: 0.36, blue: 0.72, alpha: 1)
                }),
                icon: "moon.stars"
            )
        case 5: // Flirty & Fun — rose: romantic, warm
            return Identity(
                accentColor: Color(UIColor { t in
                    t.userInterfaceStyle == .dark
                        ? UIColor(red: 0.88, green: 0.55, blue: 0.62, alpha: 1)
                        : UIColor(red: 0.78, green: 0.36, blue: 0.46, alpha: 1)
                }),
                icon: "heart"
            )
        default: // High Stakes (6) — ember: daring, high tension
            return Identity(
                accentColor: Color(UIColor { t in
                    t.userInterfaceStyle == .dark
                        ? UIColor(red: 0.92, green: 0.48, blue: 0.30, alpha: 1)
                        : UIColor(red: 0.80, green: 0.30, blue: 0.14, alpha: 1)
                }),
                icon: "flame"
            )
        }
    }
}

// MARK: - Standard Prompt Card

private struct StandardPromptCard: View {
    let prompt: GamePrompt
    let game: Game

    @State private var breathe = false

    private var identity: GamePersonality.Identity {
        GamePersonality.identity(for: game.number)
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: MomentsStyle.cardRadius)
                .fill(MomentsStyle.cardBackground)

            RoundedRectangle(cornerRadius: MomentsStyle.cardRadius)
                .fill(
                    LinearGradient(
                        colors: [
                            identity.accentColor.opacity(0.10),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: MomentsStyle.cardRadius)
                .stroke(
                    LinearGradient(
                        colors: [
                            identity.accentColor.opacity(0.35),
                            MomentsStyle.border
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )

            VStack(spacing: 24) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(identity.accentColor.opacity(0.7))
                        .frame(width: 5, height: 5)
                    Text(game.localizedName.uppercased())
                        .font(.system(size: 9, weight: .light))
                        .tracking(3)
                        .foregroundColor(MomentsStyle.secondaryText)
                }

                Text(prompt.text)
                    .font(MomentsStyle.georgiaItalic(24))
                    .foregroundColor(MomentsStyle.primaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)

                // Breathing divider
                Rectangle()
                    .fill(identity.accentColor.opacity(breathe ? 0.35 : 0.15))
                    .frame(width: 40, height: 0.5)
                    .animation(
                        .easeInOut(duration: 3.0).repeatForever(autoreverses: true),
                        value: breathe
                    )
            }
            .padding(28)
            .frame(maxWidth: .infinity, minHeight: 280)
        }
        .padding(.horizontal, 24)
        .onAppear { breathe = true }
    }
}

// MARK: - Charades Card

private struct CharadesCard: View {
    let prompt: GamePrompt
    let game: Game
    // Timer — only used when game.hasTimer is true
    var timeRemaining: Int = 0
    var timerRunning: Bool = false
    var timerExpired: Bool = false
    var onTimerTap: (() -> Void)? = nil

    private var identity: GamePersonality.Identity {
        GamePersonality.identity(for: game.number)
    }

    private var isUrgent: Bool {
        timeRemaining <= 10 && timeRemaining > 0 && timerRunning
    }

    private var timerLabel: String {
        if timerExpired {
            return Strings.gamesNext
        }
        return timerRunning ? "\(timeRemaining)s" : "\(game.timerSeconds)s"
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: MomentsStyle.cardRadius)
                .fill(MomentsStyle.cardBackground)

            RoundedRectangle(cornerRadius: MomentsStyle.cardRadius)
                .fill(
                    LinearGradient(
                        colors: [
                            identity.accentColor.opacity(0.10),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: MomentsStyle.cardRadius)
                .stroke(
                    LinearGradient(
                        colors: [
                            identity.accentColor.opacity(0.35),
                            MomentsStyle.border
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )

            VStack(spacing: 24) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(identity.accentColor.opacity(0.7))
                        .frame(width: 5, height: 5)
                    Text(game.localizedName.uppercased())
                        .font(.system(size: 9, weight: .light))
                        .tracking(3)
                        .foregroundColor(MomentsStyle.secondaryText)
                }

                Text(prompt.text)
                    .font(MomentsStyle.georgiaItalic(24))
                    .foregroundColor(MomentsStyle.primaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)

                Rectangle()
                    .fill(identity.accentColor.opacity(0.18))
                    .frame(width: 40, height: 0.5)

                if game.hasTimer {
                    Button {
                        onTimerTap?()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: timerExpired ? "arrow.trianglehead.clockwise" : (timerRunning ? "pause.fill" : "play.fill"))
                                .font(.system(size: 10, weight: .light))

                            Text(timerLabel)
                                .font(MomentsStyle.systemLight(12))
                                .tracking(1)
                        }
                        .foregroundColor(identity.accentColor.opacity(isUrgent ? 0.95 : 0.75))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(identity.accentColor.opacity(0.08))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(identity.accentColor.opacity(isUrgent ? 0.55 : 0.22), lineWidth: 0.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(28)
            .frame(maxWidth: .infinity, minHeight: 280)
        }
        .padding(.horizontal, 24)
    }

}

// MARK: - Would You Rather Card

private struct WouldYouRatherCard: View {
    let prompt: GamePrompt
    let game: Game

    @Environment(AppLanguage.self) private var appLanguage

    private var identity: GamePersonality.Identity {
        GamePersonality.identity(for: game.number)
    }

    var body: some View {
        VStack(spacing: 0) {
            optionCard(label: GameStrings.wyrOptionA, text: prompt.optionA ?? "")
                .fixedSize(horizontal: false, vertical: true)

            ZStack {
                Rectangle()
                    .fill(identity.accentColor.opacity(0.20))
                    .frame(height: 0.5)
                    .padding(.horizontal, 60)
                Text(Strings.gamesOr.uppercased())
                    .font(.system(size: 10, weight: .medium))
                    .tracking(4)
                    .foregroundColor(identity.accentColor.opacity(0.7))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(MomentsStyle.background)
            }
            .padding(.vertical, 6)

            optionCard(label: GameStrings.wyrOptionB, text: prompt.optionB ?? "")
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 24)
    }

    @ViewBuilder
    private func optionCard(label: String, text: String) -> some View {
        VStack(spacing: 8) {
            Text(label)
                .font(MomentsStyle.georgiaItalic(14))
                .foregroundColor(identity.accentColor.opacity(0.6))
            Text(text)
                .font(MomentsStyle.systemLight(17))
                .foregroundColor(MomentsStyle.primaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, minHeight: 120)
        .padding(24)
        .background(MomentsStyle.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: MomentsStyle.cardRadius))
        .overlay(
            RoundedRectangle(cornerRadius: MomentsStyle.cardRadius)
                .stroke(identity.accentColor.opacity(0.25), lineWidth: 0.5)
        )
    }
}

// MARK: - Game Completion View

private struct GameCompletionView: View {
    let game: Game
    let promptCount: Int
    let onPlayAgain: () -> Void
    let onBack: () -> Void

    @State private var appeared = false

    private var identity: GamePersonality.Identity {
        GamePersonality.identity(for: game.number)
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 28) {
                // Game emoji
                Text(game.emoji)
                    .font(.system(size: 52))
                    .scaleEffect(appeared ? 1.0 : 0.6)
                    .animation(.spring(response: 0.5, dampingFraction: 0.65).delay(0.1), value: appeared)

                VStack(spacing: 10) {
                    Text(Strings.gamesCompletionTitle)
                        .font(MomentsStyle.georgiaItalic(28))
                        .foregroundColor(MomentsStyle.primaryText)

                    Text(Strings.gamesCompletionSubtitle(promptCount))
                        .font(MomentsStyle.systemLight(15))
                        .foregroundColor(MomentsStyle.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.3).delay(0.2), value: appeared)

                // Accent divider
                Rectangle()
                    .fill(identity.accentColor.opacity(0.4))
                    .frame(width: 40, height: 0.5)
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.3).delay(0.3), value: appeared)
            }
            .padding(.horizontal, 40)

            Spacer()

            VStack(spacing: 14) {
                Button(action: onPlayAgain) {
                    Text(Strings.gamesPlayAgain)
                        .font(.system(size: 10, weight: .light))
                        .tracking(3)
                        .foregroundColor(MomentsStyle.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(MomentsStyle.primaryText)
                        .clipShape(Capsule())
                }

                Button(action: onBack) {
                    Text(Strings.gamesBackToGames)
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
            .opacity(appeared ? 1 : 0)
            .animation(.easeOut(duration: 0.3).delay(0.35), value: appeared)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MomentsStyle.background)
        .onAppear { appeared = true }
    }
}

#Preview("Charades") {
    NavigationStack {
        GamePlayView(game: lightGames[2])
    }
    .environment(AppLanguage.shared)
}

#Preview("Would You Rather") {
    NavigationStack {
        GamePlayView(game: lightGames[0])
    }
    .environment(AppLanguage.shared)
}

#Preview("Standard Game") {
    NavigationStack {
        GamePlayView(game: deepGames[0])
    }
    .environment(AppLanguage.shared)
}

#Preview("High Stakes") {
    NavigationStack {
        GamePlayView(game: deepGames[2])
    }
    .environment(AppLanguage.shared)
}
