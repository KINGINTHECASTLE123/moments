import Foundation

@Observable @MainActor
final class DrinksViewModel {
    private let drinksService: DrinksServiceProtocol

    var drinks: [FirestoreDrink] = []
    var isLoading = false
    var errorMessage: String?

    init(drinksService: (any DrinksServiceProtocol)? = nil) {
        self.drinksService = drinksService ?? DrinksService()
    }

    private func setError(_ message: String) {
        errorMessage = message
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(5))
            if self.errorMessage == message {
                self.errorMessage = nil
            }
        }
    }

    func fetchDrinks() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetchedDrinks = try await drinksService.fetchDrinks()
            drinks = fetchedDrinks.sorted {
                if $0.category == $1.category {
                    return $0.sortOrder < $1.sortOrder
                }
                return DrinkCategory.allCases.firstIndex(of: $0.category) ?? 0 <
                    DrinkCategory.allCases.firstIndex(of: $1.category) ?? 0
            }

            let imageURLs = drinks.compactMap(\.imageURL)
            await ImageCache.shared.preload(urls: imageURLs)
        } catch {
            setError("Drinks load failed: \(error.localizedDescription)")
        }

        isLoading = false
    }

    func drinks(for category: DrinkCategory) -> [FirestoreDrink] {
        drinks.filter { $0.category == category }
    }
}
