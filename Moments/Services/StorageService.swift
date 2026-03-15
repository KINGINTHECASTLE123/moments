import FirebaseStorage
import Foundation

protocol StorageServiceProtocol: Sendable {
    func uploadProfileImage(uid: String, imageData: Data) async throws -> String
    func uploadPostImage(postID: String, imageData: Data) async throws -> String
    func deletePostImage(postID: String) async throws
}

final class StorageService: StorageServiceProtocol {
    private let storage = Storage.storage().reference()

    func uploadProfileImage(uid: String, imageData: Data) async throws -> String {
        let ref = storage.child("profileImages/\(uid).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        _ = try await ref.putDataAsync(imageData, metadata: metadata)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }

    func uploadPostImage(postID: String, imageData: Data) async throws -> String {
        let ref = storage.child("postImages/\(postID).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        _ = try await ref.putDataAsync(imageData, metadata: metadata)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }

    func deletePostImage(postID: String) async throws {
        let ref = storage.child("postImages/\(postID).jpg")
        try await ref.delete()
    }
}
