import Foundation
import Observation

@Observable
@MainActor
final class AppContentViewModel {
    var landingHeroImageURL: String?
    var gamesImageURL: String?
    var musicImageURL: String?
    var foodImageURL: String?
    var drinksImageURL: String?
    var communityImageURL: String?
    var isLoading = false
    var errorMessage: String?

    private let service: AppContentService
    private var hasLoaded = false

    init(service: AppContentService? = nil) {
        self.service = service ?? AppContentService()
    }

    func fetchContentIfNeeded() async {
        guard !hasLoaded else { return }
        await fetchContent()
    }

    func fetchContent() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        do {
            async let landingContent = service.fetchLandingContent()
            async let homeContent = service.fetchHomeContent()
            let (landing, home) = try await (landingContent, homeContent)

            landingHeroImageURL = landing.heroImageURL
            gamesImageURL = home.gamesImageURL
            musicImageURL = home.musicImageURL
            foodImageURL = home.foodImageURL
            drinksImageURL = home.drinksImageURL
            communityImageURL = home.communityImageURL
            hasLoaded = true

            // Preload home tile images into cache
            var preloadURLs = [landing.heroImageURL]
            if let g = home.gamesImageURL { preloadURLs.append(g) }
            if let m = home.musicImageURL { preloadURLs.append(m) }
            if let f = home.foodImageURL { preloadURLs.append(f) }
            if let d = home.drinksImageURL { preloadURLs.append(d) }
            if let c = home.communityImageURL { preloadURLs.append(c) }
            await ImageCache.shared.preload(urls: preloadURLs)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
