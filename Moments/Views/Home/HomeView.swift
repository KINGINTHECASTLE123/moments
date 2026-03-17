import SwiftUI

enum HomeDestination: Hashable {
    case mainTabs(MomentsTab)
    case profile
    case settings
    case createMoment
    case liveMoment
}

enum HeaderFontStyle {
    case georgiaItalic
    case helveticaBold
    case spaceGrotesk
}

struct HomeView: View {
    @Environment(AppContentViewModel.self) private var appContentViewModel
    @Environment(UserViewModel.self) private var userViewModel
    @Environment(MomentPlannerViewModel.self) private var planner
    @State private var path = NavigationPath()
    @State private var showProfile = false

    var headerFontStyle: HeaderFontStyle = .georgiaItalic

    private let spacing: CGFloat = 6

    // MARK: - Font helpers

    private var headerFont: Font {
        switch headerFontStyle {
        case .georgiaItalic:  return MomentsStyle.georgiaItalic(38)
        case .helveticaBold:  return MomentsStyle.helveticaBold(34)
        case .spaceGrotesk:   return MomentsStyle.spaceGrotesk(34)
        }
    }

    private var headerText: String {
        switch headerFontStyle {
        case .georgiaItalic:  return "moments"
        case .helveticaBold:  return "MOMENTS"
        case .spaceGrotesk:   return "MOMENTS"
        }
    }

    private var tileFont: Font {
        switch headerFontStyle {
        case .georgiaItalic:  return MomentsStyle.georgiaItalic(18)
        case .helveticaBold:  return MomentsStyle.helveticaBold(16)
        case .spaceGrotesk:   return MomentsStyle.spaceGrotesk(16)
        }
    }

    private func tileLabel(_ title: String) -> String {
        switch headerFontStyle {
        case .georgiaItalic:  return title
        case .helveticaBold:  return title.uppercased()
        case .spaceGrotesk:   return title.uppercased()
        }
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                // Header
                HStack(alignment: .center) {
                    Text(headerText)
                        .font(headerFont)
                        .foregroundColor(MomentsStyle.primaryText)
                        .tracking(headerFontStyle == .georgiaItalic ? 0 : 2)

                    Spacer()

                    Button {
                        if planner.isActive {
                            path.append(HomeDestination.liveMoment)
                        } else {
                            path.append(HomeDestination.createMoment)
                        }
                    } label: {
                        Image(systemName: planner.isActive ? "sparkles" : "plus")
                            .font(.system(size: planner.isActive ? 22 : 30, weight: .regular))
                            .foregroundColor(MomentsStyle.primaryText)
                            .frame(width: 46, height: 46)
                            .background(MomentsStyle.surfaceSecondary)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, spacing + 15)
                .padding(.top, 6)
                .padding(.bottom, 8)

                // Bento Grid
                GeometryReader { geo in
                    let safeW = geo.size.width.isFinite ? max(0, geo.size.width) : 0
                    let safeH = geo.size.height.isFinite ? max(0, geo.size.height) : 0
                    let totalW = max(0, safeW - (spacing * 2))
                    let colW = max(0, (totalW - spacing) / 2)

                    // Left: Games 60%, Community 40%
                    let gamesH = max(0, (safeH - spacing) * 0.60)
                    let communityH = max(0, (safeH - spacing) * 0.40)

                    // Right: 3 equal tiles
                    let rightTileH = max(0, (safeH - (spacing * 2)) / 3)

                    HStack(alignment: .top, spacing: spacing) {
                        // Left column
                        VStack(spacing: spacing) {
                            BentoTile(
                                title: tileLabel("Games"),
                                imageURL: appContentViewModel.gamesImageURL,
                                titleFont: tileFont
                            ) {
                                path.append(HomeDestination.mainTabs(.games))
                            }
                            .frame(height: gamesH)

                            BentoTile(
                                title: tileLabel("Community"),
                                imageURL: appContentViewModel.communityImageURL,
                                titleFont: tileFont
                            ) {
                                path.append(HomeDestination.mainTabs(.community))
                            }
                            .frame(height: communityH)
                        }
                        .frame(width: colW)

                        // Right column
                        VStack(spacing: spacing) {
                            BentoTile(
                                title: tileLabel("Music"),
                                imageURL: appContentViewModel.musicImageURL,
                                titleFont: tileFont
                            ) {
                                path.append(HomeDestination.mainTabs(.music))
                            }
                            .frame(height: rightTileH)

                            BentoTile(
                                title: tileLabel("Drinks"),
                                imageURL: appContentViewModel.drinksImageURL,
                                titleFont: tileFont
                            ) {
                                path.append(HomeDestination.mainTabs(.drinks))
                            }
                            .frame(height: rightTileH)

                            BentoTile(
                                title: tileLabel("Food"),
                                imageURL: appContentViewModel.foodImageURL,
                                titleFont: tileFont
                            ) {
                                path.append(HomeDestination.mainTabs(.food))
                            }
                            .frame(height: rightTileH)
                        }
                        .frame(width: colW)
                    }
                    .padding(.horizontal, spacing)
                }

                // Bottom Bar
                HStack {
                    Button {
                        showProfile = true
                    } label: {
                        profileButtonLabel
                    }

                    Spacer()

                    Button {
                        path.append(HomeDestination.settings)
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(MomentsStyle.secondaryText)
                            .frame(width: 54, height: 54)
                            .background(MomentsStyle.surfaceSecondary)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, spacing + 15)
                .padding(.top, 8)
                .padding(.bottom, 4)
            }
            .background(MomentsStyle.background)
            .navigationBarHidden(true)
            .navigationDestination(for: HomeDestination.self) { destination in
                switch destination {
                case .mainTabs(let initialTab): MainTabView(initialTab: initialTab)
                case .profile: ProfileView()
                case .settings: SettingsView()
                case .createMoment: CreateMomentView()
                case .liveMoment: LiveMomentView()
                }
            }
        }
        .fullScreenCover(isPresented: $showProfile) {
            ProfileCoverView()
        }
        .task {
            await appContentViewModel.fetchContentIfNeeded()
        }
    }

    // MARK: - Profile Button

    @ViewBuilder
    private var profileButtonLabel: some View {
        if let imageURL = userViewModel.currentUser?.profileImageURL, !imageURL.isEmpty {
            RemoteStorageImageView(urlString: imageURL) {
                profileInitialsView
            }
            .frame(width: 54, height: 54)
            .clipShape(Circle())
        } else {
            profileInitialsView
                .frame(width: 54, height: 54)
                .clipShape(Circle())
        }
    }

    private var profileInitialsView: some View {
        ZStack {
            Circle().fill(MomentsStyle.surfaceSecondary)
            if let user = userViewModel.currentUser {
                Text(user.initials)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(MomentsStyle.secondaryText)
            } else {
                Image(systemName: "person.fill")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(MomentsStyle.secondaryText)
            }
        }
    }
}

// MARK: - Profile Cover

struct ProfileCoverView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ProfileView()
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .light))
                                .foregroundColor(MomentsStyle.primaryText)
                        }
                    }
                }
        }
        .transition(.move(edge: .leading))
    }
}

// MARK: - Bento Tile

private struct BentoTile: View {
    let title: String
    let imageURL: String?
    var titleFont: Font = MomentsStyle.georgiaItalic(18)
    var bottomInset: CGFloat = 14
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.select()
            action()
        } label: {
            GeometryReader { geo in
                let w = geo.size.width.isFinite ? max(0, geo.size.width) : 0
                let h = geo.size.height.isFinite ? max(0, geo.size.height) : 0

                ZStack(alignment: .bottomLeading) {
                    // Background image
                    if let imageURL, !imageURL.isEmpty {
                        RemoteStorageImageView(urlString: imageURL) {
                            Rectangle().fill(MomentsStyle.surfaceSecondary)
                        }
                        .frame(width: w, height: h)
                        .clipped()
                    } else {
                        Rectangle()
                            .fill(MomentsStyle.surfaceSecondary)
                    }

                    // Gradient for text legibility
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0.35),
                            .init(color: .black.opacity(0.5), location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    // Title
                    Text(title)
                        .font(titleFont)
                        .foregroundColor(.white)
                        .tracking(1)
                        .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 1)
                        .padding(.leading, 12)
                        .padding(.bottom, bottomInset)
                }
                .frame(width: w, height: h)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview("Current – Georgia Italic") {
    HomeView()
        .environment(AppContentViewModel())
        .environment(UserViewModel())
        .environment(MomentPlannerViewModel())
}
#Preview("Option A – Helvetica Bold All Caps") {
    HomeView(headerFontStyle: .helveticaBold)
        .environment(AppContentViewModel())
        .environment(UserViewModel())
        .environment(MomentPlannerViewModel())
}

#Preview("Option B – Space Grotesk All Caps") {
    HomeView(headerFontStyle: .spaceGrotesk)
        .environment(AppContentViewModel())
        .environment(UserViewModel())
        .environment(MomentPlannerViewModel())
}

