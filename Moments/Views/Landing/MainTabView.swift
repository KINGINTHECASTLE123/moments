import SwiftUI

enum MomentsTab: Int, CaseIterable, Identifiable {
    var id: Int { rawValue }
    case games, food, drinks, music, community

    var title: String {
        switch self {
        case .games: Strings.tabGames
        case .food: Strings.tabFood
        case .drinks: Strings.tabDrinks
        case .music: Strings.tabMusic
        case .community: Strings.tabCommunity
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
    @Environment(AppLanguage.self) private var appLanguage
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: MomentsTab = .games

    init(initialTab: MomentsTab = .games) {
        _selectedTab = State(initialValue: initialTab)
    }

    var body: some View {
        Group {
            switch selectedTab {
            case .games:
                NavigationStack { GamesView() }
            case .food:
                NavigationStack { FoodView() }
            case .drinks:
                NavigationStack { DrinksView() }
            case .music:
                NavigationStack { CuratedMusicView() }
            case .community:
                NavigationStack { CommunityView() }
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
                .padding(.horizontal, 8)
                .padding(.top, 10)
                .padding(.bottom, 8)
            }
            .background(MomentsStyle.cardBackground)
        }
    }
}

#Preview {
    MainTabView()
}
