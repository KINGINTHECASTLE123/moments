import FirebaseFirestore
import Foundation

enum AppContentServiceError: LocalizedError {
    case missingDocument(String)
    case missingField(documentID: String, field: String)

    var errorDescription: String? {
        switch self {
        case .missingDocument(let documentID):
            return "App content document '\(documentID)' is missing."
        case .missingField(let documentID, let field):
            return "App content document '\(documentID)' is missing field '\(field)'."
        }
    }
}

struct AppContentService {
    private let database = Firestore.firestore()

    func fetchLandingContent() async throws -> LandingContent {
        let snapshot = try await database.collection("appContent").document("landing").getDocument()

        guard snapshot.exists, let data = snapshot.data() else {
            throw AppContentServiceError.missingDocument("landing")
        }

        guard let heroImageURL = data["heroImageURL"] as? String, !heroImageURL.isEmpty else {
            throw AppContentServiceError.missingField(documentID: "landing", field: "heroImageURL")
        }

        return LandingContent(heroImageURL: heroImageURL)
    }

    func fetchHomeContent() async throws -> HomeContent {
        let snapshot = try await database.collection("appContent").document("home").getDocument()

        guard snapshot.exists, let data = snapshot.data() else {
            throw AppContentServiceError.missingDocument("home")
        }

        guard let gamesHeroImageURL = data["gamesHeroImageURL"] as? String, !gamesHeroImageURL.isEmpty else {
            throw AppContentServiceError.missingField(documentID: "home", field: "gamesHeroImageURL")
        }

        return HomeContent(gamesHeroImageURL: gamesHeroImageURL)
    }
}
