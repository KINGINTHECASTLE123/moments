import Foundation
import FirebaseFirestore

struct FirestorePost: Codable, Identifiable, Sendable, Hashable {
    @DocumentID var id: String?
    var authorUID: String
    var authorUsername: String
    var authorProfileImageURL: String?
    var body: String
    var imageURL: String?
    var tag: String?
    var likes: Int
    var likedByUIDs: [String]
    var commentCount: Int
    var createdAt: Date

    // Local-only, not stored in Firestore
    var isLiked: Bool = false

    enum CodingKeys: String, CodingKey {
        case id, authorUID, authorUsername, authorProfileImageURL
        case body, imageURL, tag, likes, likedByUIDs, commentCount, createdAt
    }
}

struct FirestoreComment: Codable, Identifiable, Sendable {
    @DocumentID var id: String?
    var authorUID: String
    var authorUsername: String
    var body: String
    var likes: Int
    var createdAt: Date
}
