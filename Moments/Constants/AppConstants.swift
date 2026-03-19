import Foundation

enum AppConstants {
    /// Valid username: 2-30 characters, alphanumeric plus dots and underscores
    static let usernamePattern = /^[a-zA-Z0-9._]{2,30}$/

    static var allInterests: [String] {
        if AppLanguage.shared.current == .danish {
            return [
                "Vinsmagning", "Brætspil", "Jazz", "Italiensk mad",
                "Cocktails", "Kunst", "Vinyl", "Sene aftener",
                "Madlavning", "Rejser", "Fotografering", "Fitness",
                "Film", "Kaffe", "Læsning", "Design"
            ]
        } else {
            return [
                "Wine Tasting", "Board Games", "Jazz", "Italian Food",
                "Cocktails", "Art", "Vinyl", "Late Nights",
                "Cooking", "Travel", "Photography", "Fitness",
                "Film", "Coffee", "Reading", "Design"
            ]
        }
    }
}

enum StorageKeys {
    static let notificationsEnabled = "notificationsEnabled"
    static let momentReminders = "momentReminders"
    static let friendActivity = "friendActivity"
    static let darkMode = "darkMode"
    static let hapticsEnabled = "hapticsEnabled"
    static let spotifyTokenMigrated = "spotifyTokenMigrated_v2"
}
