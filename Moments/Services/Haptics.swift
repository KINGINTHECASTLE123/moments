import UIKit

enum Haptics {
    private static let impactLight = UIImpactFeedbackGenerator(style: .light)
    private static let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private static let notification = UINotificationFeedbackGenerator()
    private static let selection = UISelectionFeedbackGenerator()

    private static var isEnabled: Bool {
        UserDefaults.standard.object(forKey: StorageKeys.hapticsEnabled) as? Bool ?? true
    }

    static func cardSwipe() { guard isEnabled else { return }; impactMedium.impactOccurred() }
    static func cardSettle() { guard isEnabled else { return }; impactLight.impactOccurred() }
    static func like() { guard isEnabled else { return }; impactLight.impactOccurred() }
    static func success() { guard isEnabled else { return }; notification.notificationOccurred(.success) }
    static func warning() { guard isEnabled else { return }; notification.notificationOccurred(.warning) }
    static func select() { guard isEnabled else { return }; selection.selectionChanged() }
    static func playerJoined() { guard isEnabled else { return }; impactLight.impactOccurred() }
}
