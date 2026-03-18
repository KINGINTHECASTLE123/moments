import SwiftUI

struct FoodView: View {
    @Environment(FoodViewModel.self) private var foodViewModel
    @State private var selectedCategory: FoodCategory = .starters

    private var dishes: [FirestoreDish] {
        foodViewModel.dishes(for: selectedCategory)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader("Food", subtitle: "Curated dishes for every course")
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 24)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(FoodCategory.allCases, id: \.self) { category in
                        Button {
                            Haptics.select()
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedCategory = category
                            }
                        } label: {
                            PillTag(
                                label: category.rawValue,
                                filled: selectedCategory == category
                            )
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 20)

            if foodViewModel.isLoading && foodViewModel.dishes.isEmpty {
                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(0..<3, id: \.self) { _ in
                            SkeletonCard(height: 240)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            } else if let errorMessage = foodViewModel.errorMessage, foodViewModel.dishes.isEmpty {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 36, weight: .light))
                        .foregroundColor(MomentsStyle.inactive)

                    Text("Couldn't load dishes")
                        .font(MomentsStyle.systemMedium(16))
                        .foregroundColor(MomentsStyle.primaryText)

                    Text(errorMessage)
                        .font(MomentsStyle.systemLight(13))
                        .foregroundColor(MomentsStyle.secondaryText)
                        .multilineTextAlignment(.center)

                    Button {
                        Task { await foodViewModel.fetchDishes() }
                    } label: {
                        Text("TRY AGAIN")
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
            } else if dishes.isEmpty {
                Spacer()
                Text("No dishes have been added for \(selectedCategory.rawValue.lowercased()) yet.")
                    .font(MomentsStyle.systemLight(14))
                    .foregroundColor(MomentsStyle.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                Spacer()
            } else {
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
                .refreshable {
                    Haptics.cardSettle()
                    await foodViewModel.fetchDishes()
                }
            }
        }
        .background(MomentsStyle.background)
        .navigationDestination(for: FirestoreDish.self) { dish in
            DishDetailView(dish: dish)
        }
        .task {
            if foodViewModel.dishes.isEmpty {
                await foodViewModel.fetchDishes()
            }
        }
    }
}

struct DishCard: View {
    let dish: FirestoreDish

    var body: some View {
        HairlineCard {
            VStack(alignment: .leading, spacing: 12) {
                RemoteDishImageView(urlString: dish.imageURL, height: 160, cornerRadius: 8)

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
    @Environment(\.dismiss) private var dismiss
    let dish: FirestoreDish

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ParallaxHeader(height: 320, coordinateSpace: "scroll") {
                    RemoteDishImageView(urlString: dish.imageURL, height: 320, cornerRadius: 0)
                }

                VStack(alignment: .leading, spacing: 24) {
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

                    Rectangle()
                        .fill(MomentsStyle.border)
                        .frame(height: 0.5)

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

                    Rectangle()
                        .fill(MomentsStyle.border)
                        .frame(height: 0.5)

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
        .coordinateSpace(name: "scroll")
        .background(MomentsStyle.background)
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(.container, edges: .top)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
            ToolbarItem(placement: .principal) {
                Text(dish.name)
                    .font(MomentsStyle.georgiaItalic(18))
                    .foregroundColor(MomentsStyle.primaryText)
            }
        }
    }
}

#Preview {
    NavigationStack {
        FoodView()
            .environment(FoodViewModel())
    }
}
