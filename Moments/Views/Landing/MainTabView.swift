import SwiftUI

enum MomentsTab: Int, CaseIterable {
    case games, food, drinks, music, community

    var title: String {
        switch self {
        case .games: "Games"
        case .food: "Food"
        case .drinks: "Drinks"
        case .music: "Music"
        case .community: "Community"
        }
    }

    var icon: String {
        switch self {
        case .games: "dice"
        case .food: "fork.knife"
        case .drinks: "wineglass"
        case .music: "music.note"
        case .community: "person.2"
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: MomentsTab = .games

    init(initialTab: MomentsTab = .games) {
        _selectedTab = State(initialValue: initialTab)
    }

    var body: some View {
        Group {
            switch selectedTab {
            case .games: GamesView()
            case .food: FoodView()
            case .drinks: DrinksView()
            case .music: CuratedMusicView()
            case .community: CommunityView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .transition(.opacity.animation(.easeInOut(duration: 0.15)))
        .id(selectedTab)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            // Custom tab bar
            VStack(spacing: 0) {
                // Hairline separator
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(MomentsStyle.border)

                HStack {
                    ForEach(MomentsTab.allCases, id: \.self) { tab in
                        Button {
                            Haptics.select()
                            selectedTab = tab
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: tab.icon)
                                    .font(.system(size: 20, weight: .light))
                                Text(tab.title)
                                    .font(.system(size: 10, weight: .light))
                            }
                            .foregroundColor(selectedTab == tab ? MomentsStyle.primaryText : MomentsStyle.inactive)
                            .frame(maxWidth: .infinity)
                            .accessibilityLabel(tab.title)
                            .accessibilityAddTraits(selectedTab == tab ? [.isButton, .isSelected] : .isButton)
                        }
                    }
                }
                .padding(.top, 10)
                .padding(.bottom, 8)
            }
            .background(MomentsStyle.cardBackground)
        }
    }
}

#Preview {
    NavigationStack {
        MainTabView()
    }
}
