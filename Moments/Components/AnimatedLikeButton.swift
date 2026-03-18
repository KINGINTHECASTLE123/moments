import SwiftUI

struct AnimatedLikeButton: View {
    let isLiked: Bool
    let count: Int
    let action: () -> Void

    @State private var heartScale: CGFloat = 1.0
    @State private var particles: [LikeParticle] = []

    var body: some View {
        Button {
            Haptics.like()

            // Heart bounce
            withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
                heartScale = 1.3
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
                    heartScale = 1.0
                }
            }

            // Particles only when liking
            if !isLiked {
                spawnParticles()
            }

            action()
        } label: {
            HStack(spacing: 5) {
                ZStack {
                    // Particles layer
                    ForEach(particles) { particle in
                        Circle()
                            .fill(MomentsStyle.primaryText)
                            .frame(width: 3, height: 3)
                            .offset(x: particle.x, y: particle.y)
                            .opacity(particle.opacity)
                    }

                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 13, weight: .light))
                        .scaleEffect(heartScale)
                }

                Text("\(count)")
                    .font(MomentsStyle.systemLight(12))
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.2), value: count)
            }
            .foregroundColor(isLiked ? MomentsStyle.primaryText : MomentsStyle.secondaryText)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isLiked ? "Unlike, \(count) likes" : "Like, \(count) likes")
        .accessibilityAddTraits(.isButton)
    }

    private func spawnParticles() {
        let newParticles = (0..<3).map { _ in
            LikeParticle(
                x: CGFloat.random(in: -8...8),
                targetY: CGFloat.random(in: -18 ... -12)
            )
        }
        particles.append(contentsOf: newParticles)

        withAnimation(.easeOut(duration: 0.5)) {
            for i in particles.indices where particles[i].opacity > 0 {
                particles[i].y = particles[i].targetY
                particles[i].opacity = 0
            }
        }

        // Clean up after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            particles.removeAll { $0.opacity <= 0 }
        }
    }
}

private struct LikeParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat = 0
    var opacity: Double = 1.0
    var targetY: CGFloat
}

#Preview {
    struct PreviewWrapper: View {
        @State private var liked = false
        @State private var count = 5

        var body: some View {
            VStack(spacing: 32) {
                AnimatedLikeButton(isLiked: liked, count: count) {
                    liked.toggle()
                    count += liked ? 1 : -1
                }

                AnimatedLikeButton(isLiked: true, count: 12) {}
                AnimatedLikeButton(isLiked: false, count: 0) {}
            }
            .padding()
            .background(MomentsStyle.background)
        }
    }

    return PreviewWrapper()
}
