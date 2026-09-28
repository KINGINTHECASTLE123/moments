import Foundation
import FirebaseFirestore

struct FirestorePost: Codable, Identifiable, Sendable, Hashable {
    @DocumentID var id: String?
    var authorUID: String
    var authorUsername: String
    var authorProfileImageURL: String?
    // SAFETY: `body` is user-supplied raw text. Always render via SwiftUI Text().
    // Never pass to WKWebView, NSAttributedString(html:), or any HTML renderer
    // without sanitization — doing so would expose stored XSS.
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

    init(
        id: String? = nil,
        authorUID: String,
        authorUsername: String,
        authorProfileImageURL: String?,
        body: String,
        imageURL: String?,
        tag: String?,
        likes: Int,
        likedByUIDs: [String],
        commentCount: Int,
        createdAt: Date,
        isLiked: Bool = false
    ) {
        self.id = id
        self.authorUID = authorUID
        self.authorUsername = authorUsername
        self.authorProfileImageURL = authorProfileImageURL
        self.body = body
        self.imageURL = imageURL
        self.tag = tag
        self.likes = likes
        self.likedByUIDs = likedByUIDs
        self.commentCount = commentCount
        self.createdAt = createdAt
        self.isLiked = isLiked
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        authorUID = try container.decode(String.self, forKey: .authorUID)
        authorUsername = try container.decode(String.self, forKey: .authorUsername)
        authorProfileImageURL = try container.decodeIfPresent(String.self, forKey: .authorProfileImageURL)
        body = try container.decode(String.self, forKey: .body)
        imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        tag = try container.decodeIfPresent(String.self, forKey: .tag)
        likes = try container.decodeIfPresent(Int.self, forKey: .likes) ?? 0
        likedByUIDs = try container.decodeIfPresent([String].self, forKey: .likedByUIDs) ?? []
        commentCount = try container.decodeIfPresent(Int.self, forKey: .commentCount) ?? 0
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        isLiked = false
    }
}

struct FirestoreComment: Codable, Identifiable, Sendable {
    @DocumentID var id: String?
    var authorUID: String
    var authorUsername: String
    var authorProfileImageURL: String?
    // SAFETY: Same constraint as FirestorePost.body — raw user text, SwiftUI Text() only.
    var body: String
    var likes: Int
    var likedByUIDs: [String]
    var createdAt: Date

    // Local-only, not stored in Firestore
    var isLiked: Bool = false

    enum CodingKeys: String, CodingKey {
        case id, authorUID, authorUsername, authorProfileImageURL
        case body, likes, likedByUIDs, createdAt
    }

    init(
        id: String? = nil,
        authorUID: String,
        authorUsername: String,
        authorProfileImageURL: String?,
        body: String,
        likes: Int,
        likedByUIDs: [String],
        createdAt: Date,
        isLiked: Bool = false
    ) {
        self.id = id
        self.authorUID = authorUID
        self.authorUsername = authorUsername
        self.authorProfileImageURL = authorProfileImageURL
        self.body = body
        self.likes = likes
        self.likedByUIDs = likedByUIDs
        self.createdAt = createdAt
        self.isLiked = isLiked
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        authorUID = try container.decode(String.self, forKey: .authorUID)
        authorUsername = try container.decode(String.self, forKey: .authorUsername)
        authorProfileImageURL = try container.decodeIfPresent(String.self, forKey: .authorProfileImageURL)
        body = try container.decode(String.self, forKey: .body)
        likes = try container.decodeIfPresent(Int.self, forKey: .likes) ?? 0
        likedByUIDs = try container.decodeIfPresent([String].self, forKey: .likedByUIDs) ?? []
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        isLiked = false
    }
}
