import FirebaseFirestore
import os

protocol DrinksServiceProtocol: Sendable {
    func fetchDrinks() async throws -> [FirestoreDrink]
}

final class DrinksService: DrinksServiceProtocol {
    private let db = Firestore.firestore()

    func fetchDrinks() async throws -> [FirestoreDrink] {
        let snapshot = try await db.collection("drinks").getDocuments()
        return snapshot.documents.compactMap { document in
            do {
                return try document.data(as: FirestoreDrink.self)
            } catch {
                Log.network.warning("[DrinksService] Skipping '\(document.documentID)': \(error.localizedDescription)")
                return nil
            }
        }
    }
}
