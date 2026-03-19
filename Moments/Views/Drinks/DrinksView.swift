import SwiftUI

struct DrinksView: View {
    @Environment(DrinksViewModel.self) private var drinksViewModel
    @Environment(AppLanguage.self) private var appLanguage
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: DrinkCategory = .cocktails

    private var drinks: [FirestoreDrink] {
        drinksViewModel.drinks(for: selectedCategory)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                SectionHeader(Strings.drinksTitle, subtitle: Strings.drinksSubtitle)
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 24)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(DrinkCategory.allCases, id: \.self) { category in
                        Button {
                            Haptics.select()
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedCategory = category
                            }
                        } label: {
                            PillTag(
                                label: category.displayName,
                                filled: selectedCategory == category
                            )
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 20)

            if drinksViewModel.isLoading && drinksViewModel.drinks.isEmpty {
                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(0..<3, id: \.self) { _ in
                            SkeletonCard(height: 240)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            } else if let errorMessage = drinksViewModel.errorMessage, drinksViewModel.drinks.isEmpty {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 36, weight: .light))
                        .foregroundColor(MomentsStyle.inactive)

                    Text(Strings.drinksCouldntLoad)
                        .font(MomentsStyle.systemMedium(16))
                        .foregroundColor(MomentsStyle.primaryText)

                    Text(errorMessage)
                        .font(MomentsStyle.systemLight(13))
                        .foregroundColor(MomentsStyle.secondaryText)
                        .multilineTextAlignment(.center)

                    Button {
                        Task { await drinksViewModel.fetchDrinks() }
                    } label: {
                        Text(Strings.drinksTryAgain)
                            .font(.system(size: 10, weight: .light))
                            .tracking(3)
                            .foregroundColor(MomentsStyle.primaryText)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .overlay(
                                Capsule()
                                    .stroke(MomentsStyle.border, lineWidth: 0.5)
                            )
                    }
                }
                .padding(.horizontal, 24)
                Spacer()
            } else if drinks.isEmpty {
                Spacer()
                Text(Strings.drinksEmptyState(selectedCategory.displayName))
                    .font(MomentsStyle.systemLight(14))
                    .foregroundColor(MomentsStyle.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(drinks) { drink in
                            NavigationLink(value: drink) {
                                DrinkCard(drink: drink)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
                .refreshable {
                    Haptics.cardSettle()
                    await drinksViewModel.fetchDrinks()
                }
            }
            }
            .background(MomentsStyle.background)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(MomentsStyle.primaryText)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel(Strings.tabHome)
                }
            }
            .navigationDestination(for: FirestoreDrink.self) { drink in
                DrinkDetailView(drink: drink)
            }
            .task {
                if drinksViewModel.drinks.isEmpty {
                    await drinksViewModel.fetchDrinks()
                }
            }
        }
    }
}

struct DrinkCard: View {
    let drink: FirestoreDrink

    var body: some View {
        HairlineCard {
            VStack(alignment: .leading, spacing: 12) {
                RemoteDishImageView(urlString: drink.imageURL, height: 160, cornerRadius: 8)

                Text(drink.name)
                    .font(MomentsStyle.systemMedium(16))
                    .foregroundColor(MomentsStyle.primaryText)

                Text(drink.pairing)
                    .font(MomentsStyle.systemLight(13))
                    .foregroundColor(MomentsStyle.secondaryText)

                HStack(spacing: 6) {
                    ForEach(drink.tags, id: \.self) { tag in
                        PillTag(label: tag)
                    }
                }
            }
        }
    }
}

struct DrinkDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let drink: FirestoreDrink

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ParallaxHeader(height: 320, coordinateSpace: "scroll") {
                    RemoteDishImageView(urlString: drink.imageURL, height: 320, cornerRadius: 0)
                }

                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(drink.name)
                            .font(MomentsStyle.georgiaItalic(26))
                            .foregroundColor(MomentsStyle.primaryText)

                        Text(drink.pairing)
                            .font(MomentsStyle.systemLight(14))
                            .foregroundColor(MomentsStyle.secondaryText)

                        HStack(spacing: 6) {
                            ForEach(drink.tags, id: \.self) { tag in
                                PillTag(label: tag)
                            }
                        }
                        .padding(.top, 4)
                    }

                    Rectangle()
                        .fill(MomentsStyle.border)
                        .frame(height: 0.5)

                    VStack(alignment: .leading, spacing: 12) {
                        Text(Strings.drinksIngredients)
                            .font(MomentsStyle.systemMedium(18))
                            .foregroundColor(MomentsStyle.primaryText)

                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(drink.ingredients, id: \.self) { ingredient in
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

                    Rectangle()
                        .fill(MomentsStyle.border)
                        .frame(height: 0.5)

                    VStack(alignment: .leading, spacing: 12) {
                        Text(Strings.drinksInstructions)
                            .font(MomentsStyle.systemMedium(18))
                            .foregroundColor(MomentsStyle.primaryText)

                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(Array(drink.instructions.enumerated()), id: \.offset) { index, step in
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
        .coordinateSpace(name: "scroll")
        .background(MomentsStyle.background)
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(.container, edges: .top)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(MomentsStyle.primaryText)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
            }
            ToolbarItem(placement: .principal) {
                Text(drink.name)
                    .font(MomentsStyle.georgiaItalic(18))
                    .foregroundColor(MomentsStyle.primaryText)
            }
        }
    }
}

#Preview {
    NavigationStack {
        DrinksView()
            .environment(DrinksViewModel())
            .environment(AppLanguage.shared)
    }
}
