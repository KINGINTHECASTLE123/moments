import SwiftUI

struct UserAvatarView: View {
    let imageURL: String?
    let fallbackText: String
    let size: CGFloat

    @State private var uiImage: UIImage?

    var body: some View {
        Group {
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Circle()
                    .fill(MomentsStyle.surfaceSecondary)
                    .overlay(
                        Text(fallbackText)
                            .font(.system(size: size * 0.38, weight: .medium))
                            .foregroundColor(MomentsStyle.secondaryText)
                    )
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .task(id: imageURL) {
            uiImage = nil
            guard let imageURL, !imageURL.isEmpty else { return }
            uiImage = await ImageCache.shared.image(for: imageURL)
        }
    }
}

#Preview {
    HStack(spacing: 16) {
        UserAvatarView(imageURL: nil, fallbackText: "JB", size: 34)
        UserAvatarView(imageURL: nil, fallbackText: "M", size: 40)
        UserAvatarView(imageURL: nil, fallbackText: "A", size: 30)
    }
    .padding()
}
