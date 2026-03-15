import Foundation

@Observable
final class FoodViewModel {
    private let foodService: FoodServiceProtocol

    var dishes: [FirestoreDish] = []
    var isLoading = false
    var errorMessage: String?

    init(foodService: FoodServiceProtocol = FoodService()) {
        self.foodService = foodService
    }

    @MainActor
    func fetchDishes() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetchedDishes = try await foodService.fetchDishes()
            dishes = fetchedDishes.sorted {
                if $0.category == $1.category {
                    return $0.sortOrder < $1.sortOrder
                }
                return FoodCategory.allCases.firstIndex(of: $0.category) ?? 0 <
                    FoodCategory.allCases.firstIndex(of: $1.category) ?? 0
            }
        } catch {
            errorMessage = "Food load failed: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func dishes(for category: FoodCategory) -> [FirestoreDish] {
        dishes.filter { $0.category == category }
    }
}
