import FirebaseFirestore

protocol PostServiceProtocol: Sendable {
    func fetchPosts(limit: Int) async throws -> [FirestorePost]
    func createPost(_ post: FirestorePost) async throws -> String
    func updatePost(postID: String, data: [String: Any]) async throws
    func toggleLike(postID: String, uid: String, isCurrentlyLiked: Bool) async throws
    func fetchComments(postID: String) async throws -> [FirestoreComment]
    func addComment(postID: String, comment: FirestoreComment) async throws
    func deletePost(postID: String) async throws
    func postsStream(limit: Int) -> AsyncStream<[FirestorePost]>
    func commentsStream(postID: String) -> AsyncStream<[FirestoreComment]>
}

final class PostService: PostServiceProtocol {
    private let db = Firestore.firestore()
    private var postsCollection: CollectionReference { db.collection("posts") }

    func fetchPosts(limit: Int = 20) async throws -> [FirestorePost] {
        let snapshot = try await postsCollection
            .order(by: "createdAt", descending: true)
            .limit(to: limit)
            .getDocuments()
        return try snapshot.documents.map { try $0.data(as: FirestorePost.self) }
    }

    func createPost(_ post: FirestorePost) async throws -> String {
        let ref = try postsCollection.addDocument(from: post)
        return ref.documentID
    }

    func updatePost(postID: String, data: [String: Any]) async throws {
        try await postsCollection.document(postID).updateData(data)
    }

    func toggleLike(postID: String, uid: String, isCurrentlyLiked: Bool) async throws {
        let ref = postsCollection.document(postID)
        if isCurrentlyLiked {
            try await ref.updateData([
                "likes": FieldValue.increment(Int64(-1)),
                "likedByUIDs": FieldValue.arrayRemove([uid])
            ])
        } else {
            try await ref.updateData([
                "likes": FieldValue.increment(Int64(1)),
                "likedByUIDs": FieldValue.arrayUnion([uid])
            ])
        }
    }

    func fetchComments(postID: String) async throws -> [FirestoreComment] {
        let snapshot = try await postsCollection.document(postID)
            .collection("comments")
            .order(by: "createdAt", descending: false)
            .getDocuments()
        return try snapshot.documents.map { try $0.data(as: FirestoreComment.self) }
    }

    func addComment(postID: String, comment: FirestoreComment) async throws {
        let _ = try postsCollection.document(postID)
            .collection("comments")
            .addDocument(from: comment)
        try await postsCollection.document(postID).updateData([
            "commentCount": FieldValue.increment(Int64(1))
        ])
    }

    func deletePost(postID: String) async throws {
        try await postsCollection.document(postID).delete()
    }

    func postsStream(limit: Int = 20) -> AsyncStream<[FirestorePost]> {
        AsyncStream { continuation in
            let registration = postsCollection
                .order(by: "createdAt", descending: true)
                .limit(to: limit)
                .addSnapshotListener { snapshot, error in
                    guard let snapshot else { return }
                    let posts = snapshot.documents.compactMap { doc in
                        try? doc.data(as: FirestorePost.self)
                    }
                    continuation.yield(posts)
                }
            continuation.onTermination = { @Sendable _ in
                registration.remove()
            }
        }
    }

    func commentsStream(postID: String) -> AsyncStream<[FirestoreComment]> {
        AsyncStream { continuation in
            let registration = postsCollection.document(postID)
                .collection("comments")
                .order(by: "createdAt", descending: false)
                .addSnapshotListener { snapshot, error in
                    guard let snapshot else { return }
                    let comments = snapshot.documents.compactMap { doc in
                        try? doc.data(as: FirestoreComment.self)
                    }
                    continuation.yield(comments)
                }
            continuation.onTermination = { @Sendable _ in
                registration.remove()
            }
        }
    }
}
