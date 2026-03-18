import SwiftUI

struct SwipeableCardStack<Content: View>: View {
    let totalCount: Int
    @Binding var currentIndex: Int
    var maxVisible: Int = 3
    @ViewBuilder let cardContent: (Int) -> Content

    @GestureState private var dragOffset: CGFloat = 0
    @State private var swipeOffset: CGFloat = 0
    @State private var isAnimating = false
    @State private var didHaptic = false

    private let swipeThreshold: CGFloat = 120
    private var maxVisibleCards: Int { maxVisible }

    private var dragProgress: CGFloat {
        guard !isAnimating else { return 1 }
        return min(abs(dragOffset) / swipeThreshold, 1)
    }

    var body: some View {
        ZStack {
            ForEach(visibleIndices.reversed(), id: \.self) { index in
                let depth = index - currentIndex
                if depth == 0 {
                    topCard(index: index)
                } else {
                    backgroundCard(index: index, depth: depth)
                }
            }
        }
        .animation(.easeInOut(duration: 0.22), value: currentIndex)
    }

    private var visibleIndices: [Int] {
        let start = currentIndex
        let end = min(currentIndex + maxVisibleCards, totalCount)
        guard start < end else { return [] }
        return Array(start..<end)
    }

    @ViewBuilder
    private func topCard(index: Int) -> some View {
        let totalOffset = swipeOffset + dragOffset
        cardContent(index)
            .offset(x: totalOffset)
            .rotationEffect(.degrees(Double(totalOffset) / 40))
            .transition(.asymmetric(
                insertion: .opacity,
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
            .gesture(
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
                        let translation = value.translation.width
                        let predictedEnd = value.predictedEndTranslation.width
                        let shouldSwipe = abs(translation) > swipeThreshold || abs(predictedEnd) > 300

                        if shouldSwipe {
                            animateSwipe(direction: translation > 0 ? 1 : -1)
                        } else {
                            Haptics.cardSettle()
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                swipeOffset = 0
                            }
                            didHaptic = false
                        }
                    }
            )
            .zIndex(Double(maxVisibleCards))
    }

    @ViewBuilder
    private func backgroundCard(index: Int, depth: Int) -> some View {
        let baseScale: CGFloat   = depth == 1 ? 0.95 : 0.90
        let baseOpacity: Double  = depth == 1 ? 0.75 : 0.45
        let baseYOffset: CGFloat = depth == 1 ? 8    : 16

        let targetScale: CGFloat   = depth == 1 ? 1.0  : 0.95
        let targetOpacity: Double  = depth == 1 ? 1.0  : 0.75
        let targetYOffset: CGFloat = depth == 1 ? 0    : 8

        let p = dragProgress
        let scale   = baseScale   + (targetScale   - baseScale)   * p
        let opacity = baseOpacity + (targetOpacity - baseOpacity) * p
        let yOffset = baseYOffset + (targetYOffset - baseYOffset) * p
        let blur: CGFloat = depth == 1 ? 0 : 1.0 * (1 - p)

        cardContent(index)
            .scaleEffect(scale)
            .opacity(opacity)
            .offset(y: yOffset)
            .blur(radius: blur)
            .allowsHitTesting(false)
            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: dragProgress)
            .zIndex(Double(maxVisibleCards - depth))
    }

    // Called only from gesture swipes — NEXT button handles its own advance directly
    func animateSwipe(direction: CGFloat) {
        guard !isAnimating else { return }
        isAnimating = true
        didHaptic = false

        withAnimation(.easeOut(duration: 0.25)) {
            swipeOffset = direction * 600
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            swipeOffset = 0
            if currentIndex < totalCount - 1 {
                currentIndex += 1
            }
            isAnimating = false
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var index = 0
        let prompts = [
            "What's a risk you're glad you took?",
            "When did you last change your mind about something important?",
            "What would you do with an extra hour every day?",
            "What's one thing you wish people understood about you?",
            "Describe your perfect evening."
        ]

        var body: some View {
            VStack(spacing: 24) {
                Text("\(index + 1) of \(prompts.count)")
                    .font(MomentsStyle.systemLight(13))
                    .foregroundColor(MomentsStyle.secondaryText)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.2), value: index)

                SwipeableCardStack(totalCount: prompts.count, currentIndex: $index) { i in
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
            }
            .frame(maxHeight: .infinity)
            .background(MomentsStyle.background)
        }
    }
    return PreviewWrapper()
}
