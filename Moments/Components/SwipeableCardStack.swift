import SwiftUI

struct SwipeableCardStack<Content: View>: View {
    let totalCount: Int
    @Binding var currentIndex: Int
    var maxVisible: Int = 3
    /// Increment from the parent to trigger a "next card" animation identical
    /// to a left-swipe, without directly mutating currentIndex.
    var advanceTrigger: Int = 0
    @ViewBuilder let cardContent: (Int) -> Content

    // MARK: - Gesture & animation state

    @GestureState private var dragOffset: CGFloat = 0
    @State private var swipeOffset: CGFloat = 0
    @State private var isAnimating = false
    @State private var didHaptic = false

    private let swipeThreshold: CGFloat = 120

    /// 0 → 1 as the user drags past the threshold.
    /// Forced to 1 during a programmatic swipe so background cards
    /// reach their "promoted" values before the index advances.
    private var dragProgress: CGFloat {
        if isAnimating { return 1 }
        return min(abs(dragOffset) / swipeThreshold, 1)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // ── IMPORTANT ──────────────────────────────────────────────
            // Every card goes through the SAME cardView() function.
            // There is no separate topCard()/backgroundCard() branch.
            //
            // Why: when currentIndex changes, card N+1 moves from depth 1
            // to depth 0.  If topCard/backgroundCard were separate
            // @ViewBuilder branches, SwiftUI would DESTROY the depth-1
            // view and CREATE a new depth-0 view — that's the pop.
            //
            // With a unified path the view identity stays the same and
            // only the computed modifier values change.
            // ────────────────────────────────────────────────────────────
            ForEach(visibleIndices.reversed(), id: \.self) { index in
                cardView(for: index, depth: index - currentIndex)
            }
        }
        .highPriorityGesture(swipeGesture)
        .onChange(of: advanceTrigger) { _, _ in
            guard !isAnimating, currentIndex < totalCount - 1 else { return }
            Haptics.select()
            animateSwipe(direction: -1)
        }
        // ⚠️  NO .animation(…, value: currentIndex) here.
        // That was the original source of the double-animation bug.
    }

    // MARK: - Visible indices

    private var visibleIndices: [Int] {
        let start = currentIndex
        let end = min(currentIndex + maxVisible, totalCount)
        guard start < end else { return [] }
        return Array(start..<end)
    }

    // MARK: - Unified card view

    @ViewBuilder
    private func cardView(for index: Int, depth: Int) -> some View {
        let isTop  = depth == 0
        let p      = dragProgress

        // ── Visual properties ──
        // At dragProgress == 1 the depth-1 values EQUAL the depth-0 values,
        // so promoting a card from depth 1→0 produces zero visual change.

        let scale: CGFloat = {
            if isTop { return 1.0 }
            let base:   CGFloat = depth == 1 ? 0.95 : 0.90
            let target: CGFloat = depth == 1 ? 1.0  : 0.95
            return base + (target - base) * p
        }()

        let viewOpacity: Double = {
            if isTop { return 1.0 }
            let base:   Double = depth == 1 ? 0.75 : 0.45
            let target: Double = depth == 1 ? 1.0  : 0.75
            return base + (target - base) * p
        }()

        let yOff: CGFloat = {
            if isTop { return 0 }
            let base:   CGFloat = depth == 1 ? 8  : 16
            let target: CGFloat = depth == 1 ? 0  : 8
            return base + (target - base) * p
        }()

        let blurRadius: CGFloat = {
            if isTop || depth == 1 { return 0 }
            return 1.0 * (1 - p)
        }()

        // Horizontal offset + rotation — only the top card moves.
        let xOff: CGFloat     = isTop ? swipeOffset + dragOffset : 0
        let rotation: Double  = isTop ? Double(swipeOffset + dragOffset) / 40 : 0

        cardContent(index)
            .scaleEffect(scale)
            .opacity(viewOpacity)
            .offset(x: xOff, y: yOff)
            .rotationEffect(.degrees(rotation))
            .blur(radius: blurRadius)
            .allowsHitTesting(isTop)
            .zIndex(Double(maxVisible - depth))
            // Spring-animate background cards as dragProgress changes.
            // Top card gets nil so the drag tracks 1:1 with the finger.
            .animation(
                isTop ? nil : .spring(response: 0.35, dampingFraction: 0.7),
                value: dragProgress
            )
    }

    // MARK: - Drag gesture

    private var swipeGesture: some Gesture {
        DragGesture()
            .updating($dragOffset) { value, state, _ in
                guard !isAnimating else { return }
                state = value.translation.width
            }
            .onChanged { value in
                guard !isAnimating else { return }
                if abs(value.translation.width) > swipeThreshold && !didHaptic {
                    didHaptic = true
                    Haptics.cardSwipe()
                }
            }
            .onEnded { value in
                guard !isAnimating else { return }
                let translation  = value.translation.width
                let predictedEnd = value.predictedEndTranslation.width
                let shouldSwipe  = abs(translation) > swipeThreshold
                                   || abs(predictedEnd) > 300

                if shouldSwipe {
                    animateSwipe(direction: translation > 0 ? 1 : -1)
                } else {
                    // Capture drag position into swipeOffset so we can
                    // animate the settle-back (GestureState resets instantly).
                    swipeOffset = translation
                    Haptics.cardSettle()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        swipeOffset = 0
                    }
                    didHaptic = false
                }
            }
    }

    // MARK: - Swipe animation

    /// Animates the top card off-screen, then advances the index.
    /// Used by both the drag gesture (.onEnded) and the Next button (advanceTrigger).
    private func animateSwipe(direction: CGFloat) {
        guard !isAnimating else { return }
        isAnimating = true          // → dragProgress becomes 1
        didHaptic = false

        // 1. Fly the current card off-screen.
        withAnimation(.easeOut(duration: 0.25)) {
            swipeOffset = direction * 600
        }

        // 2. After the fly-out completes, reset + advance in ONE transaction
        //    with animations disabled.
        //
        //    • swipeOffset → 0   (prevents new top card sliding from x:600)
        //    • currentIndex += 1 (ForEach updates; depth-1 card becomes depth-0)
        //
        //    Because dragProgress is still 1, the promoting card's computed
        //    scale/opacity/offset already equal the depth-0 values.
        //    Disabled-animation means zero visual change — no pop, no skip.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            var t = Transaction()
            t.disablesAnimations = true
            withTransaction(t) {
                swipeOffset = 0
                if currentIndex < totalCount - 1 {
                    currentIndex += 1
                }
            }

            // 3. Unlock after a brief settle.
            //    isAnimating → false → dragProgress drops to 0.
            //    Background cards spring-animate to their resting positions.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                isAnimating = false
            }
        }
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var index = 0
        @State private var trigger = 0
        let prompts = [
            "What's a risk you're glad you took?",
            "When did you last change your mind?",
            "What would you do with an extra hour?",
            "What do you wish people understood?",
            "Describe your perfect evening."
        ]

        var body: some View {
            VStack(spacing: 24) {
                Text("\(index + 1) of \(prompts.count)")
                    .font(MomentsStyle.systemLight(13))
                    .foregroundColor(MomentsStyle.secondaryText)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.2), value: index)

                SwipeableCardStack(
                    totalCount: prompts.count,
                    currentIndex: $index,
                    advanceTrigger: trigger
                ) { i in
                    HairlineCard {
                        Text(prompts[i])
                            .font(MomentsStyle.georgiaItalic(22))
                            .foregroundColor(MomentsStyle.primaryText)
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                            .padding(24)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 24)
                }

                Button("Next") { trigger += 1 }
                    .padding(.top, 16)
            }
            .frame(maxHeight: .infinity)
            .background(MomentsStyle.background)
        }
    }
    return PreviewWrapper()
}
