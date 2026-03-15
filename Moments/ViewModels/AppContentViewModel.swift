import Foundation
import Observation

@Observable
@MainActor
final class AppContentViewModel {
    var landingHeroImageURL: String?
    var homeGamesHeroImageURL: String?
    var isLoading = false
    var errorMessage: String?

    private let service: AppContentService
    private var hasLoaded = false

    init(service: AppContentService = AppContentService()) {
        self.service = service
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
            homeGamesHeroImageURL = home.gamesHeroImageURL
            hasLoaded = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
