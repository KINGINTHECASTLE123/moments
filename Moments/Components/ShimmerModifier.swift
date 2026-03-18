import SwiftUI

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1.0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [
                            .clear,
                            MomentsStyle.border.opacity(0.4),
                            .clear
                        ],
                        startPoint: .init(x: phase - 0.3, y: 0.5),
                        endPoint: .init(x: phase + 0.3, y: 0.5)
                    )
                    .frame(width: geo.size.width, height: geo.size.height)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: MomentsStyle.cardRadius))
            .onAppear {
                withAnimation(
                    .linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 2.0
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// Reusable skeleton card matching app style
struct SkeletonCard: View {
    var height: CGFloat = 200

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(MomentsStyle.surfaceSecondary)
                .frame(height: height * 0.6)

            RoundedRectangle(cornerRadius: 4)
                .fill(MomentsStyle.surfaceSecondary)
                .frame(width: 160, height: 14)

            RoundedRectangle(cornerRadius: 4)
                .fill(MomentsStyle.surfaceSecondary)
                .frame(width: 100, height: 12)
        }
        .padding(16)
        .background(MomentsStyle.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: MomentsStyle.cardRadius))
        .overlay(
            RoundedRectangle(cornerRadius: MomentsStyle.cardRadius)
                .stroke(MomentsStyle.border, lineWidth: 0.5)
        )
        .shimmer()
    }
}
