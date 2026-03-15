import FirebaseStorage
import UIKit

/// A two-tier image cache (NSCache in-memory + disk) with preload support.
actor ImageCache {
    static let shared = ImageCache()

    private let memoryCache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let diskCacheURL: URL

    /// Tracks in-flight downloads so multiple requests for the same URL share one network call.
    private var inFlightTasks: [String: Task<UIImage?, Never>] = [:]

    private init() {
        let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        diskCacheURL = caches.appendingPathComponent("MomentsImageCache", isDirectory: true)
        try? fileManager.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)

        memoryCache.countLimit = 80
        memoryCache.totalCostLimit = 60 * 1024 * 1024 // ~60 MB
    }

    // MARK: - Public API

    /// Returns a cached image or downloads it, caching the result.
    func image(for urlString: String) async -> UIImage? {
        let key = cacheKey(for: urlString)

        // 1. Memory
        if let cached = memoryCache.object(forKey: key as NSString) {
            return cached
        }

        // 2. Disk
        if let diskImage = loadFromDisk(key: key) {
            let cost = diskImage.cgImage.map { $0.bytesPerRow * $0.height } ?? 0
            memoryCache.setObject(diskImage, forKey: key as NSString, cost: cost)
            return diskImage
        }

        // 3. Network (coalesce duplicate requests)
        if let existing = inFlightTasks[key] {
            return await existing.value
        }

        let task = Task<UIImage?, Never> {
            let image = await download(urlString: urlString)
            if let image {
                store(image, forKey: key)
            }
            return image
        }

        inFlightTasks[key] = task
        let result = await task.value
        inFlightTasks[key] = nil
        return result
    }

    /// Preloads a batch of image URLs into cache without blocking.
    func preload(urls: [String]) {
        for url in urls where !url.isEmpty {
            let key = cacheKey(for: url)
            // Skip if already cached
            if memoryCache.object(forKey: key as NSString) != nil { continue }

            Task {
                _ = await image(for: url)
            }
        }
    }

    // MARK: - Download

    private func download(urlString: String) async -> UIImage? {
        // Firebase Storage path
        if urlString.hasPrefix("gs://") || urlString.contains("firebasestorage") {
            do {
                let data = try await Storage.storage().reference(forURL: urlString)
                    .data(maxSize: 5 * 1024 * 1024)
                return UIImage(data: data)
            } catch {
                return nil
            }
        }

        // Regular URL
        guard let url = URL(string: urlString) else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            return nil
        }
    }

    // MARK: - Disk

    private func diskPath(for key: String) -> URL {
        diskCacheURL.appendingPathComponent(key)
    }

    private func loadFromDisk(key: String) -> UIImage? {
        let path = diskPath(for: key)
        guard let data = try? Data(contentsOf: path) else { return nil }
        return UIImage(data: data)
    }

    private func store(_ image: UIImage, forKey key: String) {
        let cost = image.cgImage.map { $0.bytesPerRow * $0.height } ?? 0
        memoryCache.setObject(image, forKey: key as NSString, cost: cost)

        // Write to disk in the background
        let path = diskPath(for: key)
        Task.detached(priority: .utility) {
            if let data = image.jpegData(compressionQuality: 0.85) {
                try? data.write(to: path, options: .atomic)
            }
        }
    }

    // MARK: - Helpers

    private func cacheKey(for urlString: String) -> String {
        // Stable hash-based filename to avoid special characters in paths
        let hash = urlString.utf8.reduce(into: UInt64(5381)) { hash, byte in
            hash = hash &* 33 &+ UInt64(byte)
        }
        return String(hash, radix: 36)
    }
}
