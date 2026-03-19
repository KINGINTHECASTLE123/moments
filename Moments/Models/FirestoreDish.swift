import FirebaseFirestore
import Foundation

enum FoodCategory: String, CaseIterable, Codable, Sendable {
    case starters = "Starters"
    case mains = "Mains"
    case desserts = "Desserts"

    var displayName: String {
        switch self {
        case .starters: return Strings.foodCategoryStarters
        case .mains: return Strings.foodCategoryMains
        case .desserts: return Strings.foodCategoryDesserts
        }
    }
}

enum DrinkCategory: String, CaseIterable, Codable, Sendable {
    case cocktails = "Cocktails"
    case juices = "Juices"
    case mocktails = "Mocktails"

    var displayName: String {
        switch self {
        case .cocktails: return Strings.drinksCategoryCocktails
        case .juices: return Strings.drinksCategoryJuices
        case .mocktails: return Strings.drinksCategoryMocktails
        }
    }
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
