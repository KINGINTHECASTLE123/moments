import SwiftUI

struct HairlineCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: MomentsStyle.cardRadius))
            .overlay(
                RoundedRectangle(cornerRadius: MomentsStyle.cardRadius)
                    .stroke(MomentsStyle.border, lineWidth: 0.5)
            )
    }
}

#Preview {
    HairlineCard {
        Text("Card content")
            .font(MomentsStyle.systemRegular(14))
    }
    .padding()
}
