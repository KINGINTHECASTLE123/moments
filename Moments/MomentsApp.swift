import SwiftUI
import FirebaseCore

@main
struct MomentsApp: App {
    @State private var authViewModel: AuthViewModel
    @State private var userViewModel: UserViewModel
    @State private var communityViewModel: CommunityViewModel
    @State private var foodViewModel: FoodViewModel
    @State private var appContentViewModel: AppContentViewModel
    @State private var musicViewModel: MusicViewModel
    @AppStorage("darkMode") private var darkMode = false

    init() {
        FirebaseApp.configure()
        _authViewModel = State(initialValue: AuthViewModel())
        _userViewModel = State(initialValue: UserViewModel())
        _communityViewModel = State(initialValue: CommunityViewModel())
        _foodViewModel = State(initialValue: FoodViewModel())
        _appContentViewModel = State(initialValue: AppContentViewModel())
        _musicViewModel = State(initialValue: MusicViewModel())
    }

    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authViewModel)
                .environment(userViewModel)
                .environment(communityViewModel)
                .environment(foodViewModel)
                .environment(appContentViewModel)
                .environment(musicViewModel)
                .preferredColorScheme(darkMode ? .dark : .light)
                .onOpenURL { url in
                    print(">>> onOpenURL received: \(url.absoluteString)")
                    print(">>> URL scheme: \(url.scheme ?? "nil")")
                    musicViewModel.handleURL(url)
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                musicViewModel.connect()
            } else if newPhase == .background {
                musicViewModel.disconnect()
            }
        }
    }
}
