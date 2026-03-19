import FirebaseFirestore

protocol MomentHistoryServiceProtocol: Sendable {
    func saveMoment(_ moment: CompletedMoment, uid: String) async throws
    func fetchRecentMoments(uid: String, limit: Int) async throws -> [CompletedMoment]
}

final class MomentHistoryService: MomentHistoryServiceProtocol {
    private let db = Firestore.firestore()

    private func historyCollection(uid: String) -> CollectionReference {
        db.collection("users").document(uid).collection("moments")
    }

    func saveMoment(_ moment: CompletedMoment, uid: String) async throws {
        let ref = historyCollection(uid: uid).document()
        try ref.setData(from: moment)
        // Increment the user's momentsCount atomically
        try await db.collection("users").document(uid).updateData([
            "momentsCount": FieldValue.increment(Int64(1))
        ])
    }

    func fetchRecentMoments(uid: String, limit: Int) async throws -> [CompletedMoment] {
        let snapshot = try await historyCollection(uid: uid)
            .order(by: "endedAt", descending: true)
            .limit(to: limit)
            .getDocuments()
        return try snapshot.documents.map { try $0.data(as: CompletedMoment.self) }
    }
}
