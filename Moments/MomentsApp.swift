import SwiftUI
import FirebaseCore
import os

@main
struct MomentsApp: App {
    @State private var authViewModel: AuthViewModel
    @State private var userViewModel: UserViewModel
    @State private var communityViewModel: CommunityViewModel
    @State private var foodViewModel: FoodViewModel
    @State private var drinksViewModel: DrinksViewModel
    @State private var appContentViewModel: AppContentViewModel
    @State private var musicViewModel: MusicViewModel
    @State private var momentPlannerViewModel: MomentPlannerViewModel
    @State private var notificationService: NotificationService
    @State private var appLanguage = AppLanguage.shared
    @AppStorage(StorageKeys.darkMode) private var darkMode = false

    init() {
        FirebaseApp.configure()
        // One-time migration: clear any stale Spotify token that predates the
        // invalid_grant fix, so the user gets a clean connect prompt instead of
        // an error loop on first launch after updating.
        if !UserDefaults.standard.bool(forKey: StorageKeys.spotifyTokenMigrated) {
            KeychainService.delete(key: "spotify_access_token")
            UserDefaults.standard.set(true, forKey: StorageKeys.spotifyTokenMigrated)
        }
        _authViewModel = State(initialValue: AuthViewModel())
        _userViewModel = State(initialValue: UserViewModel())
        _communityViewModel = State(initialValue: CommunityViewModel())
        _foodViewModel = State(initialValue: FoodViewModel())
        _drinksViewModel = State(initialValue: DrinksViewModel())
        _appContentViewModel = State(initialValue: AppContentViewModel())
        _musicViewModel = State(initialValue: MusicViewModel())
        _momentPlannerViewModel = State(initialValue: MomentPlannerViewModel())
        _notificationService = State(initialValue: NotificationService())
    }

    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authViewModel)
                .environment(userViewModel)
                .environment(communityViewModel)
                .environment(foodViewModel)
                .environment(drinksViewModel)
                .environment(appContentViewModel)
                .environment(musicViewModel)
                .environment(momentPlannerViewModel)
                .environment(notificationService)
                .environment(appLanguage)
                .preferredColorScheme(darkMode ? .dark : .light)
                .onOpenURL { url in
                    Log.general.debug("Deep link received")
                    musicViewModel.handleURL(url)
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                musicViewModel.connect()
                Task {
                    await ImageCache.shared.cleanupDiskCache()
                    await notificationService.refreshAuthorizationStatus()
                    let remindersEnabled = UserDefaults.standard.object(forKey: StorageKeys.momentReminders) as? Bool ?? true
                    let notificationsEnabled = UserDefaults.standard.object(forKey: StorageKeys.notificationsEnabled) as? Bool ?? true
                    if notificationsEnabled && remindersEnabled {
                        await notificationService.updateMomentReminders(enabled: true)
                    }
                }
            } else if newPhase == .background {
                musicViewModel.disconnect()
            }
        }
    }
}
