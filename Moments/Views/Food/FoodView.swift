import SwiftUI

struct Dish: Identifiable {
    let id = UUID()
    let name: String
    let pairing: String
    let tags: [String]
}

private let starters: [Dish] = [
    Dish(name: "Burrata & Heirloom Tomato", pairing: "Pairs with Aperol Spritz", tags: ["Vegetarian"]),
    Dish(name: "Tuna Tartare", pairing: "Pairs with Dry Martini", tags: ["Seafood"]),
]

private let mains: [Dish] = [
    Dish(name: "Slow-Roasted Lamb", pairing: "Pairs with Bordeaux Red", tags: ["Meat"]),
    Dish(name: "Pan-Seared Sea Bass", pairing: "Pairs with Sancerre", tags: ["Seafood"]),
]

private let desserts: [Dish] = [
    Dish(name: "Dark Chocolate Fondant", pairing: "Pairs with Espresso Martini", tags: ["Indulgent"]),
    Dish(name: "Panna Cotta & Berries", pairing: "Pairs with Moscato d'Asti", tags: ["Light"]),
]

private let cocktails: [Dish] = [
    Dish(name: "Negroni", pairing: "Bitter, balanced, timeless", tags: ["Classic"]),
    Dish(name: "Espresso Martini", pairing: "Bold coffee meets smooth vodka", tags: ["Popular"]),
    Dish(name: "Paloma", pairing: "Grapefruit, tequila, fizz", tags: ["Refreshing"]),
]

struct FoodView: View {
    @State private var selectedCategory = 0
    private let categories = ["Starters", "Mains", "Desserts", "Cocktails"]

    private var dishes: [Dish] {
        switch selectedCategory {
        case 0: starters
        case 1: mains
        case 2: desserts
        case 3: cocktails
        default: starters
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                SectionHeader("Food & Drinks", subtitle: "Curated pairings for every course")
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 24)

                // Segmented control
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(0..<categories.count, id: \.self) { index in
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedCategory = index
                                }
                            } label: {
                                PillTag(
                                    label: categories[index],
                                    filled: selectedCategory == index
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 20)

                // Dish cards
                VStack(spacing: 14) {
                    ForEach(dishes) { dish in
                        DishCard(dish: dish)
                    }
                }
                .padding(.horizontal, 24)

                Spacer(minLength: 32)
            }
        }
        .background(MomentsStyle.background)
    }
}

struct DishCard: View {
    let dish: Dish

    var body: some View {
        HairlineCard {
            VStack(alignment: .leading, spacing: 12) {
                // Image placeholder
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0.96, green: 0.955, blue: 0.945))
                    .frame(height: 160)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 24, weight: .light))
                            .foregroundColor(MomentsStyle.inactive)
                    )

                Text(dish.name)
                    .font(MomentsStyle.systemMedium(16))
                    .foregroundColor(MomentsStyle.primaryText)

                Text(dish.pairing)
                    .font(MomentsStyle.systemLight(13))
                    .foregroundColor(MomentsStyle.secondaryText)

                HStack(spacing: 6) {
                    ForEach(dish.tags, id: \.self) { tag in
                        PillTag(label: tag)
                    }
                }
            }
        }
    }
}

#Preview {
    FoodView()
}
