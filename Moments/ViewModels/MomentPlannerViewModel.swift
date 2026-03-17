import Foundation
import Observation

@Observable @MainActor
final class MomentPlannerViewModel {
    private static let storageKey = "currentMomentPlan"

    var currentPlan: MomentPlan?

    var isActive: Bool { currentPlan?.isActive ?? false }

    var elapsedTime: TimeInterval {
        guard let startedAt = currentPlan?.startedAt else { return 0 }
        return Date().timeIntervalSince(startedAt)
    }

    init() {
        load()
    }

    // MARK: - Create

    func createFromTemplate(_ template: MomentTemplate) {
        currentPlan = MomentPlan(
            title: template.name,
            vibe: template.vibe,
            playlistId: template.suggestedPlaylistId,
            dishIds: template.suggestedDishIds,
            gameNumbers: template.suggestedGameNumbers
        )
        save()
    }

    func createCustom() {
        currentPlan = MomentPlan()
        save()
    }

    // MARK: - Update

    func setPlaylist(_ playlistId: String) {
        currentPlan?.playlistId = playlistId
        save()
    }

    func setDishes(_ dishIds: [String]) {
        currentPlan?.dishIds = dishIds
        save()
    }

    func setGames(_ gameNumbers: [Int]) {
        currentPlan?.gameNumbers = gameNumbers
        save()
    }

    func setTitle(_ title: String) {
        currentPlan?.title = title
        save()
    }

    // MARK: - Lifecycle

    func startMoment() {
        currentPlan?.isActive = true
        currentPlan?.startedAt = Date()
        save()
    }

    func endMoment() {
        currentPlan = nil
        save()
    }

    // MARK: - Persistence

    private func save() {
        guard let plan = currentPlan else {
            UserDefaults.standard.removeObject(forKey: Self.storageKey)
            return
        }
        if let data = try? JSONEncoder().encode(plan) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: Self.storageKey),
              let plan = try? JSONDecoder().decode(MomentPlan.self, from: data) else {
            return
        }
        currentPlan = plan
    }
}
