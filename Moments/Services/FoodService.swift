import FirebaseFirestore
import os

protocol FoodServiceProtocol: Sendable {
    func fetchDishes() async throws -> [FirestoreDish]
}

final class FoodService: FoodServiceProtocol {
    private let db = Firestore.firestore()

    func fetchDishes() async throws -> [FirestoreDish] {
        let snapshot = try await db.collection("dishes").getDocuments()
        return snapshot.documents.compactMap { document in
            do {
                return try document.data(as: FirestoreDish.self)
            } catch {
                Log.network.warning("[FoodService] Skipping '\(document.documentID)': \(error.localizedDescription)")
                return nil
            }
        }
    }
}
