import UIKit

enum ImageCompressor {
    /// Compresses image data to JPEG with max dimension and quality.
    /// Returns compressed data or nil if input is invalid.
    static func compress(
        data: Data,
        maxDimension: CGFloat = 1200,
        quality: CGFloat = 0.75
    ) -> Data? {
        guard let image = UIImage(data: data) else { return nil }

        let size = image.size
        let ratio = min(maxDimension / size.width, maxDimension / size.height, 1.0)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)

        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }

        return resized.jpegData(compressionQuality: quality)
    }
}
