import Foundation
import FirebaseFirestore

struct UserProfile: Codable, Identifiable, Sendable {
    @DocumentID var id: String?
    var fullName: String
    var username: String
    var email: String
    var bio: String
    var interests: [String]
    var profileImageURL: String?
    var momentsCount: Int
    var friendsCount: Int
    var likesCount: Int
    var createdAt: Date

    var initials: String {
        let parts = fullName.split(separator: " ")
        let firstInitial = parts.first?.prefix(1) ?? ""
        let lastInitial = parts.count > 1 ? parts.last!.prefix(1) : ""
        return "\(firstInitial)\(lastInitial)".uppercased()
    }

    var firstInitial: String {
        String(fullName.prefix(1)).uppercased()
    }
}
