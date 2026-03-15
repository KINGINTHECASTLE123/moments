import FirebaseFirestore

protocol UserServiceProtocol: Sendable {
    func createUser(_ profile: UserProfile, uid: String) async throws
    func fetchUser(uid: String) async throws -> UserProfile
    func updateUser(uid: String, data: [String: Any]) async throws
    func deleteUserData(uid: String) async throws
}

final class UserService: UserServiceProtocol {
    private let db = Firestore.firestore()
    private var usersCollection: CollectionReference { db.collection("users") }

    func createUser(_ profile: UserProfile, uid: String) async throws {
        try usersCollection.document(uid).setData(from: profile)
    }

    func fetchUser(uid: String) async throws -> UserProfile {
        let snapshot = try await usersCollection.document(uid).getDocument()
        return try snapshot.data(as: UserProfile.self)
    }

    func updateUser(uid: String, data: [String: Any]) async throws {
        try await usersCollection.document(uid).updateData(data)
    }

    func deleteUserData(uid: String) async throws {
        try await usersCollection.document(uid).delete()
    }
}
