import FirebaseFirestore
import Foundation

enum FoodCategory: String, CaseIterable, Codable, Sendable {
    case starters = "Starters"
    case mains = "Mains"
    case desserts = "Desserts"
}

enum DrinkCategory: String, CaseIterable, Codable, Sendable {
    case cocktails = "Cocktails"
    case juices = "Juices"
    case mocktails = "Mocktails"
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

struct FirestoreDrink: Codable, Identifiable, Hashable, Sendable {
    @DocumentID var id: String?
    var name: String
    var pairing: String
    var tags: [String]
    var imageURL: String?
    var ingredients: [String]
    var instructions: [String]
    var category: DrinkCategory
    var sortOrder: Int
}
