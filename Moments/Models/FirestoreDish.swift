import FirebaseFirestore
import Foundation

enum FoodCategory: String, CaseIterable, Codable, Sendable {
    case starters = "Starters"
    case mains = "Mains"
    case desserts = "Desserts"
    case cocktails = "Cocktails"
}

struct FirestoreDish: Codable, Identifiable, Hashable, Sendable {
    @DocumentID var id: String?
    var name: String
    var pairing: String
    var tags: [String]
    var imageURL: String?
    var ingredients: [String]
    var instructions: [String]
    var category: FoodCategory
    var sortOrder: Int
}
