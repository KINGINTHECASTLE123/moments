import SwiftUI

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

        uiImage = await ImageCache.shared.image(for: urlString)
    }
}
