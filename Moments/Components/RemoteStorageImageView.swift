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
        .accessibilityLabel("Food image")
    }
}

struct RemoteStorageImageView<Placeholder: View>: View {
    let urlString: String?
    let contentMode: ContentMode
    let placeholder: Placeholder
    let onImageLoaded: ((Bool) -> Void)?

    @State private var uiImage: UIImage?

    init(
        urlString: String?,
        contentMode: ContentMode = .fill,
        onImageLoaded: ((Bool) -> Void)? = nil,
        @ViewBuilder placeholder: () -> Placeholder
    ) {
        self.urlString = urlString
        self.contentMode = contentMode
        self.onImageLoaded = onImageLoaded
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
        onImageLoaded?(false)

        guard let urlString, !urlString.isEmpty else {
            return
        }

        // If the string is a local asset name (no URL scheme), load from the bundle directly.
        let looksLikeURL = urlString.contains("://") || urlString.hasPrefix("http")
        if !looksLikeURL {
            uiImage = UIImage(named: urlString)
            onImageLoaded?(uiImage != nil)
            return
        }

        uiImage = await ImageCache.shared.image(for: urlString)
        onImageLoaded?(uiImage != nil)
    }
}
