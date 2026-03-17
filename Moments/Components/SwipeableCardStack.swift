import SwiftUI

struct SwipeableCardStack<Content: View>: View {
    let totalCount: Int
    @Binding var currentIndex: Int
    @ViewBuilder let cardContent: (Int) -> Content

    @GestureState private var dragOffset: CGFloat = 0
    @State private var swipeOffset: CGFloat = 0
    @State private var didSwipe = false
    @State private var cardID = UUID()

    private let swipeThreshold: CGFloat = 120
    private let maxVisibleCards = 3

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
        .onChange(of: currentIndex) { _, _ in
            cardID = UUID()
        }
    }

    // MARK: - Visible Indices

    private var visibleIndices: [Int] {
        let start = currentIndex
        let end = min(currentIndex + maxVisibleCards, totalCount)
        guard start < end else { return [] }
        return Array(start..<end)
    }

    // MARK: - Top Card

    private func topCard(index: Int) -> some View {
        cardContent(index)
            .id(cardID)
            .offset(x: swipeOffset + dragOffset)
            .rotationEffect(.degrees(Double(swipeOffset + dragOffset) / 25))
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation.width
                    }
                    .onChanged { value in
                        let total = value.translation.width
                        if abs(total) > swipeThreshold && !didSwipe {
                            didSwipe = true
                            Haptics.cardSwipe()
                        }
                    }
                    .onEnded { value in
                        let translation = value.translation.width
                        if abs(translation) > swipeThreshold {
                            let direction: CGFloat = translation > 0 ? 1 : -1
                            withAnimation(.easeOut(duration: 0.25)) {
                                swipeOffset = direction * 500
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                swipeOffset = 0
                                didSwipe = false
                                if currentIndex < totalCount - 1 {
                                    currentIndex += 1
                                }
                            }
                        } else {
                            Haptics.cardSettle()
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                swipeOffset = 0
                            }
                            didSwipe = false
                        }
                    }
            )
            .transition(.opacity.combined(with: .offset(y: 8)))
            .animation(.easeOut(duration: 0.2).delay(0.05), value: cardID)
            .zIndex(Double(maxVisibleCards))
    }

    // MARK: - Background Card

    private func backgroundCard(index: Int, depth: Int) -> some View {
        let scale = 1.0 - 0.04 * Double(depth)
        let opacity = depth == 1 ? 0.6 : 0.3
        let yOffset = 6.0 * Double(depth)
        let blur = 1.5 * Double(depth)

        return cardContent(index)
            .scaleEffect(scale)
            .opacity(opacity)
            .offset(y: yOffset)
            .blur(radius: blur)
            .allowsHitTesting(false)
            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: currentIndex)
            .zIndex(Double(maxVisibleCards - depth))
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
