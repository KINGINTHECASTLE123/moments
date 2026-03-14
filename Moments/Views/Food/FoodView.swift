import SwiftUI

struct Dish: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let pairing: String
    let tags: [String]
    let imageName: String?
    let ingredients: [String]
    let instructions: [String]
}

private let starters: [Dish] = [
    Dish(
        name: "Burrata & Heirloom Tomato",
        pairing: "Pairs with Aperol Spritz",
        tags: ["Vegetarian"],
        imageName: "FoodBurrata",
        ingredients: [
            "1 large burrata (200g)",
            "4 heirloom tomatoes, mixed colors",
            "Fresh basil leaves",
            "Extra virgin olive oil",
            "Flaky sea salt & black pepper",
            "1 tbsp aged balsamic vinegar",
            "1 tbsp capers"
        ],
        instructions: [
            "Slice the heirloom tomatoes into thick wedges and arrange on a serving plate.",
            "Season the tomatoes generously with flaky sea salt and let rest for 5 minutes.",
            "Place the burrata in the center of the plate and tear it open gently.",
            "Scatter fresh basil leaves over the dish and sprinkle with capers.",
            "Drizzle with extra virgin olive oil and aged balsamic vinegar.",
            "Finish with freshly cracked black pepper and serve immediately."
        ]
    ),
    Dish(
        name: "Tuna Tartare",
        pairing: "Pairs with Dry Martini",
        tags: ["Seafood"],
        imageName: "FoodTunaTartare",
        ingredients: [
            "300g sushi-grade tuna, finely diced",
            "2 spring onions, thinly sliced",
            "1 tbsp sesame oil",
            "1 tbsp soy sauce",
            "1 tsp freshly grated ginger",
            "1 tbsp sesame seeds",
            "Juice of 1 lime",
            "Micro herbs for garnish"
        ],
        instructions: [
            "Dice the sushi-grade tuna into small, even cubes and place in a chilled bowl.",
            "Combine sesame oil, soy sauce, grated ginger, and lime juice in a small bowl.",
            "Pour the dressing over the tuna and gently fold to combine without crushing.",
            "Cover and refrigerate for 10 minutes to let the flavors meld.",
            "Use a ring mold to plate the tartare neatly in the center of a chilled plate.",
            "Top with sliced spring onions, sesame seeds, and micro herbs. Serve immediately."
        ]
    ),
]

private let mains: [Dish] = [
    Dish(
        name: "Slow-Roasted Lamb",
        pairing: "Pairs with Bordeaux Red",
        tags: ["Meat"],
        imageName: "FoodLamb",
        ingredients: [
            "1.5kg lamb shoulder, bone-in",
            "6 cloves garlic, crushed",
            "Fresh rosemary & thyme sprigs",
            "2 tbsp olive oil",
            "1 cup red wine",
            "Salt & pepper to taste"
        ],
        instructions: [
            "Preheat oven to 160°C. Score the lamb and rub with garlic, herbs, oil, salt and pepper.",
            "Place in a roasting pan and pour in the red wine.",
            "Cover tightly with foil and roast for 4 hours until fork-tender.",
            "Remove foil for the last 30 minutes to crisp the exterior.",
            "Rest for 15 minutes before serving. Spoon pan juices over the lamb."
        ]
    ),
    Dish(
        name: "Pan-Seared Sea Bass",
        pairing: "Pairs with Sancerre",
        tags: ["Seafood"],
        imageName: "FoodSeaBass",
        ingredients: [
            "2 sea bass fillets, skin-on",
            "2 tbsp olive oil",
            "2 tbsp butter",
            "1 lemon, halved",
            "Fresh dill",
            "Salt & pepper"
        ],
        instructions: [
            "Pat the sea bass fillets dry and season with salt and pepper.",
            "Heat olive oil in a pan over high heat until shimmering.",
            "Place fillets skin-side down and press gently. Cook for 4 minutes.",
            "Flip and add butter, lemon halves, and dill to the pan.",
            "Baste the fillets with the butter for 2 minutes until just cooked through.",
            "Serve immediately with a squeeze of charred lemon."
        ]
    ),
]

private let desserts: [Dish] = [
    Dish(
        name: "Dark Chocolate Fondant",
        pairing: "Pairs with Espresso Martini",
        tags: ["Indulgent"],
        imageName: "FoodChocolateFondant",
        ingredients: [
            "200g dark chocolate (70%)",
            "150g butter",
            "3 eggs + 3 yolks",
            "75g caster sugar",
            "50g plain flour",
            "Cocoa powder for dusting"
        ],
        instructions: [
            "Melt the chocolate and butter together over a bain-marie. Let cool slightly.",
            "Whisk the eggs, yolks, and sugar until pale and thick.",
            "Fold the chocolate mixture into the eggs, then sift in the flour and fold gently.",
            "Pour into buttered, cocoa-dusted ramekins. Chill for at least 1 hour.",
            "Bake at 200°C for 12 minutes. The center should be soft.",
            "Turn out onto plates and serve immediately with vanilla ice cream."
        ]
    ),
    Dish(
        name: "Panna Cotta & Berries",
        pairing: "Pairs with Moscato d'Asti",
        tags: ["Light"],
        imageName: "FoodPannaCotta",
        ingredients: [
            "500ml double cream",
            "75g caster sugar",
            "1 vanilla pod, split",
            "2 sheets leaf gelatine",
            "Mixed berries for serving",
            "Mint leaves for garnish"
        ],
        instructions: [
            "Soak the gelatine sheets in cold water for 5 minutes.",
            "Heat the cream, sugar, and vanilla seeds gently until just simmering.",
            "Remove from heat, squeeze excess water from gelatine, and stir into the cream.",
            "Pour into moulds and refrigerate for at least 4 hours until set.",
            "Turn out onto plates and top with fresh mixed berries and mint."
        ]
    ),
]

private let cocktails: [Dish] = [
    Dish(
        name: "Negroni",
        pairing: "Bitter, balanced, timeless",
        tags: ["Classic"],
        imageName: "FoodNegroni",
        ingredients: [
            "30ml gin",
            "30ml Campari",
            "30ml sweet vermouth",
            "Orange peel for garnish",
            "Ice"
        ],
        instructions: [
            "Add gin, Campari, and sweet vermouth to a mixing glass with ice.",
            "Stir for 30 seconds until well chilled.",
            "Strain into a rocks glass over a large ice cube.",
            "Express an orange peel over the drink and drop it in."
        ]
    ),
    Dish(
        name: "Espresso Martini",
        pairing: "Bold coffee meets smooth vodka",
        tags: ["Popular"],
        imageName: "FoodEspressoMartini",
        ingredients: [
            "50ml vodka",
            "30ml fresh espresso",
            "15ml coffee liqueur",
            "10ml simple syrup",
            "3 coffee beans for garnish"
        ],
        instructions: [
            "Brew a fresh shot of espresso and let it cool slightly.",
            "Add vodka, espresso, coffee liqueur, and simple syrup to a shaker with ice.",
            "Shake vigorously for 15 seconds to build a frothy top.",
            "Double strain into a chilled coupe glass.",
            "Garnish with three coffee beans on top of the foam."
        ]
    ),
    Dish(
        name: "Paloma",
        pairing: "Grapefruit, tequila, fizz",
        tags: ["Refreshing"],
        imageName: "FoodPaloma",
        ingredients: [
            "50ml tequila blanco",
            "100ml grapefruit soda",
            "15ml fresh lime juice",
            "Pinch of salt",
            "Grapefruit wedge for garnish"
        ],
        instructions: [
            "Rim a highball glass with salt and fill with ice.",
            "Pour in the tequila and fresh lime juice.",
            "Top with grapefruit soda and stir gently.",
            "Garnish with a grapefruit wedge and serve."
        ]
    ),
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
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader("Food & Drinks", subtitle: "Curated pairings for every course")
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 24)

            // Fixed category pills
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

            // Scrollable dish list
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(dishes) { dish in
                        NavigationLink(value: dish) {
                            DishCard(dish: dish)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .background(MomentsStyle.background)
        .navigationDestination(for: Dish.self) { dish in
            DishDetailView(dish: dish)
        }
    }
}

struct DishCard: View {
    let dish: Dish

    var body: some View {
        HairlineCard {
            VStack(alignment: .leading, spacing: 12) {
                // Dish image
                if let imageName = dish.imageName {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: 0.96, green: 0.955, blue: 0.945))
                        .frame(height: 160)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 24, weight: .light))
                                .foregroundColor(MomentsStyle.inactive)
                        )
                }

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

struct DishDetailView: View {
    let dish: Dish

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Hero image
                if let imageName = dish.imageName {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 320)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color(red: 0.96, green: 0.955, blue: 0.945))
                        .frame(height: 320)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 32, weight: .light))
                                .foregroundColor(MomentsStyle.inactive)
                        )
                }

                VStack(alignment: .leading, spacing: 24) {
                    // Title and pairing
                    VStack(alignment: .leading, spacing: 8) {
                        Text(dish.name)
                            .font(MomentsStyle.georgiaItalic(26))
                            .foregroundColor(MomentsStyle.primaryText)

                        Text(dish.pairing)
                            .font(MomentsStyle.systemLight(14))
                            .foregroundColor(MomentsStyle.secondaryText)

                        HStack(spacing: 6) {
                            ForEach(dish.tags, id: \.self) { tag in
                                PillTag(label: tag)
                            }
                        }
                        .padding(.top, 4)
                    }

                    // Divider
                    Rectangle()
                        .fill(MomentsStyle.border)
                        .frame(height: 0.5)

                    // Ingredients
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ingredients")
                            .font(MomentsStyle.systemMedium(18))
                            .foregroundColor(MomentsStyle.primaryText)

                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(dish.ingredients, id: \.self) { ingredient in
                                HStack(alignment: .top, spacing: 12) {
                                    Circle()
                                        .fill(MomentsStyle.primaryText)
                                        .frame(width: 5, height: 5)
                                        .padding(.top, 6)

                                    Text(ingredient)
                                        .font(MomentsStyle.systemLight(15))
                                        .foregroundColor(MomentsStyle.primaryText)
                                }
                            }
                        }
                    }

                    // Divider
                    Rectangle()
                        .fill(MomentsStyle.border)
                        .frame(height: 0.5)

                    // Instructions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Instructions")
                            .font(MomentsStyle.systemMedium(18))
                            .foregroundColor(MomentsStyle.primaryText)

                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(Array(dish.instructions.enumerated()), id: \.offset) { index, step in
                                HStack(alignment: .top, spacing: 14) {
                                    Text("\(index + 1)")
                                        .font(MomentsStyle.systemMedium(14))
                                        .foregroundColor(MomentsStyle.secondaryText)
                                        .frame(width: 20, alignment: .center)

                                    Text(step)
                                        .font(MomentsStyle.systemLight(15))
                                        .foregroundColor(MomentsStyle.primaryText)
                                        .lineSpacing(3)
                                }
                            }
                        }
                    }
                }
                .padding(24)
            }
        }
        .background(MomentsStyle.background)
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(.container, edges: .top)
    }
}

#Preview {
    NavigationStack {
        FoodView()
    }
}

#Preview("Dish Detail") {
    NavigationStack {
        DishDetailView(dish: starters[0])
    }
}
