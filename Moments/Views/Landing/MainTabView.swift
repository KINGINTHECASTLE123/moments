import SwiftUI

enum MomentsTab: Int, CaseIterable {
    case games, food, music, community

    var title: String {
        switch self {
        case .games: "Games"
        case .food: "Food & Drinks"
        case .music: "Music"
        case .community: "Community"
        }
    }

    var icon: String {
        switch self {
        case .games: "dice"
        case .food: "fork.knife"
        case .music: "music.note"
        case .community: "person.2"
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: MomentsTab = .games

    var body: some View {
        VStack(spacing: 0) {
            // Content
            Group {
                switch selectedTab {
                case .games: GamesView()
                case .food: FoodView()
                case .music: MusicView()
                case .community: CommunityView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Hairline separator
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(MomentsStyle.border)

            // Custom tab bar
            HStack {
                ForEach(MomentsTab.allCases, id: \.self) { tab in
                    Button {
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
                    }
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 4)
            .background(Color.white)
        }
    }
}

#Preview {
    MainTabView()
}
