import SwiftUI

enum HomeDestination: Hashable {
    case games
    case food
    case music
    case community
    case profile
    case settings
}

struct HomeView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(spacing: 0) {
                    // Navbar
                    HomeNavBar(
                        onProfile: { path.append(HomeDestination.profile) },
                        onSettings: { path.append(HomeDestination.settings) }
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 24)

                    // Stacked content boxes
                    VStack(spacing: 16) {
                        // Games — hero card (primary feature)
                        HomeHeroCard(
                            title: "Games",
                            subtitle: "Break the ice, spark the night",
                            icon: "dice",
                            badge: "6 games",
                            imageName: "GamesPhoto"
                        ) {
                            path.append(HomeDestination.games)
                        }

                        // Two-column row: Food & Music
                        HStack(spacing: 14) {
                            HomeSquareCard(
                                title: "Food & Drinks",
                                subtitle: "Curated pairings",
                                icon: "fork.knife"
                            ) {
                                path.append(HomeDestination.food)
                            }

                            HomeSquareCard(
                                title: "Music",
                                subtitle: "Set the mood",
                                icon: "music.note"
                            ) {
                                path.append(HomeDestination.music)
                            }
                        }

                        // Community — wide card
                        HomeWideCard(
                            title: "Community",
                            subtitle: "See what's happening around you",
                            icon: "person.2",
                            itemCount: "4 new posts"
                        ) {
                            path.append(HomeDestination.community)
                        }

                        // Profile — compact card
                        HomeWideCard(
                            title: "Profile",
                            subtitle: "Your moments, your people",
                            icon: "person.crop.circle",
                            itemCount: "12 moments"
                        ) {
                            path.append(HomeDestination.profile)
                        }
                    }
                    .padding(.horizontal, 24)

                    // Bottom breathing room
                    Spacer(minLength: 40)
                }
            }
            .background(MomentsStyle.background)
            .navigationBarHidden(true)
            .navigationDestination(for: HomeDestination.self) { destination in
                switch destination {
                case .games: GamesView()
                case .food: FoodView()
                case .music: MusicView()
                case .community: CommunityView()
                case .profile: ProfileView()
                case .settings: SettingsView()
                }
            }
        }
    }
}

// MARK: - Navbar

struct HomeNavBar: View {
    var onProfile: () -> Void
    var onSettings: () -> Void

    var body: some View {
        HStack {
            // Profile avatar
            Button(action: onProfile) {
                Circle()
                    .fill(Color(red: 0.96, green: 0.955, blue: 0.945))
                    .frame(width: 34, height: 34)
                    .overlay(
                        Text("J")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(MomentsStyle.secondaryText)
                    )
            }

            Spacer()

            // Wordmark
            Text("moments")
                .font(MomentsStyle.georgiaItalic(22))
                .foregroundColor(MomentsStyle.primaryText)

            Spacer()

            // Settings gear
            Button(action: onSettings) {
                Image(systemName: "gearshape")
                    .font(.system(size: 18, weight: .light))
                    .foregroundColor(MomentsStyle.primaryText)
            }
        }
    }
}

// MARK: - Hero Card (full width, tall)

struct HomeHeroCard: View {
    let title: String
    let subtitle: String
    let icon: String
    var badge: String? = nil
    var imageName: String? = nil
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                // Image area
                Group {
                    if let imageName {
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 0.96, green: 0.955, blue: 0.945))
                            .frame(height: 200)
                            .overlay(
                                Image(systemName: icon)
                                    .font(.system(size: 36, weight: .light))
                                    .foregroundColor(MomentsStyle.inactive)
                            )
                    }
                }
                .padding(.bottom, 18)

                HStack(alignment: .firstTextBaseline) {
                    Text(title)
                        .font(MomentsStyle.georgiaItalic(28))
                        .foregroundColor(MomentsStyle.primaryText)

                    Spacer()

                    if let badge {
                        Text(badge.uppercased())
                            .font(.system(size: 9, weight: .light))
                            .tracking(2)
                            .foregroundColor(MomentsStyle.secondaryText)
                    }
                }

                Text(subtitle)
                    .font(MomentsStyle.systemLight(13))
                    .foregroundColor(MomentsStyle.secondaryText)
                    .padding(.top, 4)

                // Arrow
                HStack {
                    Spacer()
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(MomentsStyle.secondaryText)
                }
                .padding(.top, 14)
            }
            .padding(20)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: MomentsStyle.cardRadius))
            .overlay(
                RoundedRectangle(cornerRadius: MomentsStyle.cardRadius)
                    .stroke(MomentsStyle.border, lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Square Card (half width)

struct HomeSquareCard: View {
    let title: String
    let subtitle: String
    let icon: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .light))
                    .foregroundColor(MomentsStyle.primaryText)

                Spacer()

                Text(title)
                    .font(MomentsStyle.georgiaItalic(18))
                    .foregroundColor(MomentsStyle.primaryText)

                Text(subtitle)
                    .font(MomentsStyle.systemLight(11))
                    .foregroundColor(MomentsStyle.secondaryText)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 150)
            .padding(18)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: MomentsStyle.cardRadius))
            .overlay(
                RoundedRectangle(cornerRadius: MomentsStyle.cardRadius)
                    .stroke(MomentsStyle.border, lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Wide Card

struct HomeWideCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let itemCount: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(MomentsStyle.georgiaItalic(24))
                        .foregroundColor(MomentsStyle.primaryText)

                    Text(subtitle)
                        .font(MomentsStyle.systemLight(12))
                        .foregroundColor(MomentsStyle.secondaryText)

                    Text(itemCount.uppercased())
                        .font(.system(size: 9, weight: .light))
                        .tracking(2)
                        .foregroundColor(MomentsStyle.secondaryText)
                        .padding(.top, 8)
                }

                Spacer()

                Image(systemName: icon)
                    .font(.system(size: 32, weight: .light))
                    .foregroundColor(MomentsStyle.inactive)
            }
            .padding(20)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: MomentsStyle.cardRadius))
            .overlay(
                RoundedRectangle(cornerRadius: MomentsStyle.cardRadius)
                    .stroke(MomentsStyle.border, lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView()
}
