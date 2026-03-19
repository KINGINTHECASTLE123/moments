import Foundation
import os
import UserNotifications
import Observation

@Observable @MainActor
final class NotificationService {
    private let center = UNUserNotificationCenter.current()
    private let reminderIdentifierPrefix = "moment-reminder-"

    private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    // MARK: - Permissions

    func requestAuthorization() async {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            if granted {
                await refreshAuthorizationStatus()
            }
        } catch {
            Log.notifications.error("Authorization error: \(error.localizedDescription, privacy: .private)")
        }
        await refreshAuthorizationStatus()
    }

    func refreshAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    // MARK: - Moment Reminders

    /// Schedules a daily reminder to capture a moment at the given hour/minute.
    func scheduleMomentReminders() async {
        // Remove existing reminders first
        cancelMomentReminders()

        guard authorizationStatus == .authorized else { return }

        let messages = Strings.notificationMessages

        // Schedule a daily reminder at 19:00
        var dateComponents = DateComponents()
        dateComponents.hour = 19
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let content = UNMutableNotificationContent()
        content.title = Strings.notificationTitle
        content.body = messages.randomElement() ?? messages[0]
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "\(reminderIdentifierPrefix)daily",
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            Log.notifications.error("Failed to schedule reminder: \(error.localizedDescription, privacy: .private)")
        }
    }

    func cancelMomentReminders() {
        center.removePendingNotificationRequests(
            withIdentifiers: ["\(reminderIdentifierPrefix)daily"]
        )
    }

    /// Convenience to toggle reminders on/off based on a boolean.
    func updateMomentReminders(enabled: Bool) async {
        if enabled {
            await scheduleMomentReminders()
        } else {
            cancelMomentReminders()
        }
    }
}
