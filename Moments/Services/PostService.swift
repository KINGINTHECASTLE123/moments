import FirebaseFirestore
import os

protocol PostServiceProtocol: Sendable {
    func fetchPosts(limit: Int) async throws -> [FirestorePost]
    func fetchCommentCount(postID: String) async throws -> Int
    func createPost(_ post: FirestorePost) async throws -> String
    func setPostImageURL(postID: String, imageURL: String) async throws
    func toggleLike(postID: String, uid: String, isCurrentlyLiked: Bool) async throws
    func fetchComments(postID: String) async throws -> [FirestoreComment]
    func addComment(postID: String, comment: FirestoreComment) async throws
    func toggleCommentLike(postID: String, commentID: String, uid: String, isCurrentlyLiked: Bool) async throws
    func deletePost(postID: String) async throws
    func deleteComment(postID: String, commentID: String) async throws
    func reportPost(postID: String, reporterUID: String, reason: String) async throws
    func reportComment(postID: String, commentID: String, reporterUID: String, reason: String) async throws
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
        return try snapshot.documents.map { document in
            var post = try document.data(as: FirestorePost.self)
            post.id = document.documentID
            return post
        }
    }

    func fetchCommentCount(postID: String) async throws -> Int {
        let snapshot = try await postsCollection.document(postID)
            .collection("comments")
            .getDocuments()
        return snapshot.documents.compactMap { document in
            try? document.data(as: FirestoreComment.self)
        }.count
    }

    func createPost(_ post: FirestorePost) async throws -> String {
        let ref = try postsCollection.addDocument(from: post)
        return ref.documentID
    }

    func setPostImageURL(postID: String, imageURL: String) async throws {
        try await postsCollection.document(postID).updateData(["imageURL": imageURL])
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
        return try snapshot.documents.map { document in
            var comment = try document.data(as: FirestoreComment.self)
            comment.id = document.documentID
            return comment
        }
    }

    func addComment(postID: String, comment: FirestoreComment) async throws {
        let postRef = postsCollection.document(postID)
        let commentRef = postRef.collection("comments").document()
        try commentRef.setData(from: comment)
        do {
            try await postRef.updateData([
                "commentCount": FieldValue.increment(Int64(1))
            ])
        } catch {
            Log.network.error("Failed to increment commentCount for post \(postID, privacy: .public): \(error.localizedDescription, privacy: .public)")
        }
    }

    func toggleCommentLike(postID: String, commentID: String, uid: String, isCurrentlyLiked: Bool) async throws {
        let ref = postsCollection.document(postID)
            .collection("comments")
            .document(commentID)
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

    func deletePost(postID: String) async throws {
        // Delete all comments in the subcollection first
        let commentsSnapshot = try await postsCollection.document(postID)
            .collection("comments")
            .getDocuments()

        // Use a batch for atomic deletion
        if !commentsSnapshot.documents.isEmpty {
            let batch = db.batch()
            for commentDoc in commentsSnapshot.documents {
                batch.deleteDocument(commentDoc.reference)
            }
            try await batch.commit()
        }

        // Then delete the post itself
        try await postsCollection.document(postID).delete()
    }

    func deleteComment(postID: String, commentID: String) async throws {
        let postRef = postsCollection.document(postID)
        let commentRef = postRef.collection("comments").document(commentID)
        try await commentRef.delete()
        do {
            try await postRef.updateData([
                "commentCount": FieldValue.increment(Int64(-1))
            ])
        } catch {
            Log.network.error("Failed to decrement commentCount for post \(postID, privacy: .public): \(error.localizedDescription, privacy: .public)")
        }
    }

    func reportPost(postID: String, reporterUID: String, reason: String) async throws {
        // Document ID is a composite key to prevent duplicate reports from the same user
        let reportID = "\(reporterUID)_\(postID)"
        let data: [String: Any] = [
            "reporterUID": reporterUID,
            "postID": postID,
            "reason": reason,
            "createdAt": FieldValue.serverTimestamp()
        ]
        try await db.collection("reports").document(reportID).setData(data)
    }

    func reportComment(postID: String, commentID: String, reporterUID: String, reason: String) async throws {
        // Composite key prevents duplicate reports from the same user on the same comment
        let reportID = "\(reporterUID)_\(postID)_\(commentID)"
        let data: [String: Any] = [
            "reporterUID": reporterUID,
            "postID": postID,
            "commentID": commentID,
            "reason": reason,
            "createdAt": FieldValue.serverTimestamp()
        ]
        try await db.collection("reports").document(reportID).setData(data)
    }

    func postsStream(limit: Int = 20) -> AsyncStream<[FirestorePost]> {
        AsyncStream { continuation in
            let registration = postsCollection
                .order(by: "createdAt", descending: true)
                .limit(to: limit)
                .addSnapshotListener { snapshot, error in
                    guard let snapshot else { return }
                    let posts: [FirestorePost] = snapshot.documents.compactMap { doc -> FirestorePost? in
                        guard var post = try? doc.data(as: FirestorePost.self) else { return nil }
                        post.id = doc.documentID
                        return post
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
                    let comments: [FirestoreComment] = snapshot.documents.compactMap { doc -> FirestoreComment? in
                        guard var comment = try? doc.data(as: FirestoreComment.self) else { return nil }
                        comment.id = doc.documentID
                        return comment
                    }
                    continuation.yield(comments)
                }
            continuation.onTermination = { @Sendable _ in
                registration.remove()
            }
        }
    }
}
