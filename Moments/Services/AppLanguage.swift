import SwiftUI

enum Language: String, CaseIterable {
    case english = "en"
    case danish = "da"

    var displayName: String {
        switch self {
        case .english: return "English"
        case .danish: return "Dansk"
        }
    }

    var flag: String {
        switch self {
        case .english: return "🇬🇧"
        case .danish: return "🇩🇰"
        }
    }
}

@Observable @MainActor
final class AppLanguage {
    static let shared = AppLanguage()

    var current: Language {
        didSet {
            UserDefaults.standard.set(current.rawValue, forKey: "appLanguage")
        }
    }

    private init() {
        let stored = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        self.current = Language(rawValue: stored) ?? .english
    }
}
