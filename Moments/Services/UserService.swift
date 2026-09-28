import FirebaseFirestore
import FirebaseStorage

protocol UserServiceProtocol: Sendable {
    func createUser(_ profile: UserProfile, uid: String) async throws
    func fetchUser(uid: String) async throws -> UserProfile
    func updateUser(uid: String, data: [String: Any]) async throws
    func deleteUserData(uid: String) async throws
    func deleteAllUserData(uid: String) async throws
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

    /// Deletes all data associated with a user: posts (and their comments + images),
    /// profile image, and user document. Call before deleting the Firebase Auth account.
    func deleteAllUserData(uid: String) async throws {
        let db = Firestore.firestore()

        // 1. Find and delete all posts by the user
        let postsSnapshot = try await db.collection("posts")
            .whereField("authorUID", isEqualTo: uid)
            .getDocuments()

        for doc in postsSnapshot.documents {
            let postID = doc.documentID

            // Batch-delete all comments + the post document in one round-trip
            let commentsSnapshot = try await doc.reference
                .collection("comments")
                .getDocuments()

            let batch = db.batch()
            for commentDoc in commentsSnapshot.documents {
                batch.deleteDocument(commentDoc.reference)
            }
            batch.deleteDocument(doc.reference)
            try await batch.commit()

            // Delete post image from Storage if it exists
            if let imageURL = doc.data()["imageURL"] as? String, !imageURL.isEmpty {
                let imageRef = Storage.storage().reference()
                    .child("postImages/\(uid)_\(postID).jpg")
                try? await imageRef.delete()
            }
        }

        // 2. Delete profile image from Storage
        let profileRef = Storage.storage().reference()
            .child("profileImages/\(uid).jpg")
        try? await profileRef.delete()

        // 3. Delete user document
        try await usersCollection.document(uid).delete()
    }
}
