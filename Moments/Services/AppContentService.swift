import FirebaseFirestore
import FirebaseStorage
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
    private nonisolated(unsafe) let storage = Storage.storage().reference()

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
        let basePath = "content/home"
        let files = ["games.jpg", "music.jpg", "food.jpg", "drinks.jpg", "community.jpg"]

        // Fetch download URLs for all home tile images from Storage
        var urls: [String: String] = [:]
        await withTaskGroup(of: (String, String?).self) { group in
            for file in files {
                group.addTask {
                    let ref = self.storage.child("\(basePath)/\(file)")
                    do {
                        let url = try await ref.downloadURL()
                        return (file, url.absoluteString)
                    } catch {
                        return (file, nil)
                    }
                }
            }
            for await (file, url) in group {
                if let url { urls[file] = url }
            }
        }

        return HomeContent(
            gamesImageURL: urls["games.jpg"],
            musicImageURL: urls["music.jpg"],
            foodImageURL: urls["food.jpg"],
            drinksImageURL: urls["drinks.jpg"],
            communityImageURL: urls["community.jpg"]
        )
    }
}
