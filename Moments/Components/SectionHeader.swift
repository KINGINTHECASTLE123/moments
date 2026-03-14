import SwiftUI

struct SectionHeader: View {
    let title: String
    let subtitle: String?

    init(_ title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(MomentsStyle.georgiaItalic(34))
                .foregroundColor(MomentsStyle.primaryText)

            if let subtitle {
                Text(subtitle)
                    .font(MomentsStyle.systemLight(14))
                    .foregroundColor(MomentsStyle.secondaryText)
            }
        }
    }
}

#Preview {
    SectionHeader("Games", subtitle: "Break the ice")
        .padding()
}
