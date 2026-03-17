import FirebaseFirestore

enum DrinksServiceError: LocalizedError {
    case decodeFailed(documentID: String, underlyingError: Error)
    case missingField(documentID: String, field: String)
    case invalidField(documentID: String, field: String)

    var errorDescription: String? {
        switch self {
        case .decodeFailed(let documentID, let underlyingError):
            return "Failed to decode drink '\(documentID)': \(underlyingError.localizedDescription)"
        case .missingField(let documentID, let field):
            return "Drink '\(documentID)' is missing field '\(field)'."
        case .invalidField(let documentID, let field):
            return "Drink '\(documentID)' has invalid field '\(field)'."
        }
    }
}

protocol DrinksServiceProtocol: Sendable {
    func fetchDrinks() async throws -> [FirestoreDrink]
}

final class DrinksService: DrinksServiceProtocol {
    private let db = Firestore.firestore()

    func fetchDrinks() async throws -> [FirestoreDrink] {
        let snapshot = try await db.collection("drinks").getDocuments()
        return snapshot.documents.compactMap { document in
            do {
                return try decodeDrink(from: document)
            } catch {
                print("[DrinksService] Skipping document '\(document.documentID)': \(error.localizedDescription)")
                return nil
            }
        }
    }

    private func decodeDrink(from document: QueryDocumentSnapshot) throws -> FirestoreDrink {
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
        guard let category = DrinkCategory(rawValue: categoryRawValue) else {
            throw DrinksServiceError.invalidField(documentID: documentID, field: "category")
        }
        let sortOrder: Int
        if let intVal = data["sortOrder"] as? Int {
            sortOrder = intVal
        } else if let doubleVal = data["sortOrder"] as? Double {
            sortOrder = Int(doubleVal)
        } else {
            throw missingOrInvalidField(documentID: documentID, field: "sortOrder", value: data["sortOrder"])
        }

        return FirestoreDrink(
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

    private func missingOrInvalidField(documentID: String, field: String, value: Any?) -> DrinksServiceError {
        if value == nil {
            return .missingField(documentID: documentID, field: field)
        }
        return .invalidField(documentID: documentID, field: field)
    }
}
