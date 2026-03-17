import SwiftUI

struct ParallaxHeader<Content: View>: View {
    let height: CGFloat
    let coordinateSpace: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        GeometryReader { geo in
            let offset = geo.frame(in: .named(coordinateSpace)).minY
            let isOverscroll = offset > 0

            content()
                .frame(width: geo.size.width, height: height + (isOverscroll ? offset : 0))
                .clipped()
                .offset(y: isOverscroll ? -offset + offset * 0.4 : 0)
                .scaleEffect(isOverscroll ? 1 + offset / 1000 : 1, anchor: .center)
        }
        .frame(height: height)
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            VStack(spacing: 0) {
                ParallaxHeader(height: 260, coordinateSpace: "scroll") {
                    ZStack {
                        MomentsStyle.surfaceSecondary
                        Image(systemName: "dice")
                            .font(.system(size: 48, weight: .light))
                            .foregroundColor(MomentsStyle.primaryText)
                    }
                }

                VStack(alignment: .leading, spacing: 16) {
                    Text("Parallax Demo")
                        .font(MomentsStyle.georgiaItalic(26))
                        .foregroundColor(MomentsStyle.primaryText)

                    ForEach(0..<20) { i in
                        Text("Row \(i)")
                            .font(MomentsStyle.systemLight(14))
                            .foregroundColor(MomentsStyle.secondaryText)
                    }
                }
                .padding(24)
            }
        }
        .coordinateSpace(name: "scroll")
        .background(MomentsStyle.background)
    }
}
