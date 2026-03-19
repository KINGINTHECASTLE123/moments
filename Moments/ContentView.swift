import SwiftUI

enum LandingChoice {
    case signIn, createAccount
}

struct ContentView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(AppContentViewModel.self) private var appContentViewModel
    @Environment(UserViewModel.self) private var userViewModel
    @Environment(CommunityViewModel.self) private var communityViewModel
    @Environment(FoodViewModel.self) private var foodViewModel
    @Environment(DrinksViewModel.self) private var drinksViewModel
    @State private var landingChoice: LandingChoice?
    @State private var isAppReady = false

    var body: some View {
        ZStack {
            Group {
                switch authViewModel.authState {
                case .unknown:
                    Color.clear

                case .signedOut:
                    if let choice = landingChoice {
                        NavigationStack {
                            switch choice {
                            case .signIn:
                                SignInView()
                            case .createAccount:
                                CreateAccountView()
                            }
                        }
                    } else {
                        LandingView(
                            onCreateAccount: {
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    landingChoice = .createAccount
                                }
                            },
                            onSignIn: {
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    landingChoice = .signIn
                                }
                            }
                        )
                    }

                case .signedIn(let uid):
                    HomeView()
                        .task(id: uid) {
                            // Fetch user profile and preload all content images in parallel,
                            // while enforcing a minimum splash duration for a smoother experience
                            async let minimumDelay: Void = Task.sleep(nanoseconds: 2_500_000_000)
                            await withTaskGroup(of: Void.self) { group in
                                group.addTask { await userViewModel.fetchCurrentUser(uid: uid) }
                                group.addTask { await foodViewModel.fetchDishes() }
                                group.addTask { await drinksViewModel.fetchDrinks() }
                            }
                            _ = try? await minimumDelay
                            withAnimation(.easeInOut(duration: 0.6)) {
                                isAppReady = true
                            }
                        }
                }
            }

            // Splash overlay: shown during auth check and initial signed-in data load
            if !isAppReady {
                AppSplashView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .task {
            // Start fetching content URLs (hero image etc.) as early as possible
            await appContentViewModel.fetchContentIfNeeded()
        }
        .onChange(of: authViewModel.authState) { _, newValue in
            if case .signedOut = newValue {
                landingChoice = nil
                isAppReady = true  // Show landing page immediately, no splash needed
                userViewModel.clear()
                communityViewModel.stopListening()
                communityViewModel.stopCommentsListener()
            }
        }
    }
}

// MARK: - Splash View

private struct AppSplashView: View {
    @Environment(AppContentViewModel.self) private var appContentViewModel
    @State private var showWordmark = false

    var body: some View {
        ZStack {
            // Hero image background (fades in when loaded, dark gradient fallback)
            RemoteStorageImageView(urlString: appContentViewModel.landingHeroImageURL) {
                Color.black
            }
            .aspectRatio(contentMode: .fill)
            .ignoresSafeArea()

            // Overlay for legibility
            Color.black.opacity(0.45)
                .ignoresSafeArea()

            // Wordmark
            Text("moments")
                .font(MomentsStyle.georgiaItalic(62))
                .foregroundColor(.white)
                .opacity(showWordmark ? 1 : 0)
                .offset(y: showWordmark ? 0 : 16)
                .animation(.easeOut(duration: 1.2).delay(0.2), value: showWordmark)
        }
        .onAppear { showWordmark = true }
    }
}

#Preview {
    ContentView()
        .environment(AuthViewModel())
        .environment(UserViewModel())
        .environment(CommunityViewModel())
        .environment(FoodViewModel())
        .environment(DrinksViewModel())
        .environment(AppContentViewModel())
}
