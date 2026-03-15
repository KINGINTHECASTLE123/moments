import FirebaseStorage
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

        if let image = await loadFirebaseStorageImage(urlString: urlString) {
            uiImage = image
        } else if let image = await loadRemoteImage(urlString: urlString) {
            uiImage = image
        }
    }

    private func loadFirebaseStorageImage(urlString: String) async -> UIImage? {
        guard urlString.hasPrefix("gs://") || urlString.contains("firebasestorage") else {
            return nil
        }

        do {
            let data = try await Storage.storage().reference(forURL: urlString).data(maxSize: 5 * 1024 * 1024)
            return UIImage(data: data)
        } catch {
            return nil
        }
    }

    private func loadRemoteImage(urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else {
            return nil
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            return nil
        }
    }
}
