import FirebaseFirestore

enum FoodServiceError: LocalizedError {
    case decodeFailed(documentID: String, underlyingError: Error)
    case missingField(documentID: String, field: String)
    case invalidField(documentID: String, field: String)

    var errorDescription: String? {
        switch self {
        case .decodeFailed(let documentID, let underlyingError):
            return "Failed to decode dish '\(documentID)': \(underlyingError.localizedDescription)"
        case .missingField(let documentID, let field):
            return "Dish '\(documentID)' is missing field '\(field)'."
        case .invalidField(let documentID, let field):
            return "Dish '\(documentID)' has invalid field '\(field)'."
        }
    }
}

protocol FoodServiceProtocol: Sendable {
    func fetchDishes() async throws -> [FirestoreDish]
}

final class FoodService: FoodServiceProtocol {
    private let db = Firestore.firestore()

    func fetchDishes() async throws -> [FirestoreDish] {
        let snapshot = try await db.collection("dishes").getDocuments()
        return try snapshot.documents.map { document in
            try decodeDish(from: document)
        }
    }

    private func decodeDish(from document: QueryDocumentSnapshot) throws -> FirestoreDish {
        let data = document.data()
        let documentID = document.documentID

        guard let name = data["name"] as? String else {
            throw missingOrInvalidField(documentID: documentID, field: "name", value: data["name"])
        }
        guard let pairing = data["pairing"] as? String else {
            throw missingOrInvalidField(documentID: documentID, field: "pairing", value: data["pairing"])
        }
        guard let tags = data["tags"] as? [String] else {
            throw missingOrInvalidField(documentID: documentID, field: "tags", value: data["tags"])
        }
        let imageURL = data["imageURL"] as? String
        guard let ingredients = data["ingredients"] as? [String] else {
            throw missingOrInvalidField(documentID: documentID, field: "ingredients", value: data["ingredients"])
        }
        guard let instructions = data["instructions"] as? [String] else {
            throw missingOrInvalidField(documentID: documentID, field: "instructions", value: data["instructions"])
        }
        guard let categoryRawValue = data["category"] as? String else {
            throw missingOrInvalidField(documentID: documentID, field: "category", value: data["category"])
        }
        guard let category = FoodCategory(rawValue: categoryRawValue) else {
            throw FoodServiceError.invalidField(documentID: documentID, field: "category")
        }
        guard let sortOrder = data["sortOrder"] as? Int else {
            throw missingOrInvalidField(documentID: documentID, field: "sortOrder", value: data["sortOrder"])
        }

        return FirestoreDish(
            id: documentID,
            name: name,
            pairing: pairing,
            tags: tags,
            imageURL: imageURL,
            ingredients: ingredients,
            instructions: instructions,
            category: category,
            sortOrder: sortOrder
        )
    }

    private func missingOrInvalidField(documentID: String, field: String, value: Any?) -> FoodServiceError {
        if value == nil {
            return .missingField(documentID: documentID, field: field)
        }
        return .invalidField(documentID: documentID, field: field)
    }
}
