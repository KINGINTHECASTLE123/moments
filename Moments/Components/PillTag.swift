import SwiftUI

struct PillTag: View {
    let label: String
    var filled: Bool = false

    var body: some View {
        Text(label.uppercased())
            .font(.system(size: 9, weight: .light))
            .tracking(2)
            .foregroundColor(filled ? .white : MomentsStyle.primaryText)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(filled ? MomentsStyle.primaryText : Color.clear)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(filled ? Color.clear : MomentsStyle.border, lineWidth: 0.5)
            )
    }
}

#Preview {
    HStack {
        PillTag(label: "Games")
        PillTag(label: "Food", filled: true)
        PillTag(label: "Music")
    }
    .padding()
}
