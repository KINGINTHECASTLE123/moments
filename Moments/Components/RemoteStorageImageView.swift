import SwiftUI

/// A convenience wrapper around RemoteStorageImageView for fixed-height image tiles
/// used in Food and Drinks cards/detail views.
struct RemoteDishImageView: View {
    let urlString: String?
    let height: CGFloat
    let cornerRadius: CGFloat

    var body: some View {
        RemoteStorageImageView(urlString: urlString) {
            Rectangle()
                .fill(MomentsStyle.surfaceSecondary)
                .overlay(ProgressView())
        }
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

struct RemoteStorageImageView<Placeholder: View>: View {
    let urlString: String?
    let contentMode: ContentMode
    let placeholder: Placeholder

    @State private var uiImage: UIImage?

    init(
        urlString: String?,
        contentMode: ContentMode = .fill,
        @ViewBuilder placeholder: () -> Placeholder
    ) {
        self.urlString = urlString
        self.contentMode = contentMode
        self.placeholder = placeholder()
    }

    var body: some View {
        Group {
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                placeholder
            }
        }
        .task(id: urlString) {
            await loadImage()
        }
    }

    @MainActor
    private func loadImage() async {
        uiImage = nil

        guard let urlString, !urlString.isEmpty else {
            return
        }

        // If the string is a local asset name (no URL scheme), load from the bundle directly.
        let looksLikeURL = urlString.contains("://") || urlString.hasPrefix("http")
        if !looksLikeURL {
            uiImage = UIImage(named: urlString)
            return
        }

        uiImage = await ImageCache.shared.image(for: urlString)
    }
}
