import Foundation
import Observation

@Observable @MainActor
final class MomentPlannerViewModel {
    private static let storageKey = "currentMomentPlan"

    private let historyService: MomentHistoryServiceProtocol

    var currentPlan: MomentPlan?
    var recentMoments: [CompletedMoment] = []
    var isLoadingHistory = false

    var isActive: Bool { currentPlan?.isActive ?? false }

    var elapsedTime: TimeInterval {
        guard let startedAt = currentPlan?.startedAt else { return 0 }
        return Date().timeIntervalSince(startedAt)
    }

    init(historyService: (any MomentHistoryServiceProtocol)? = nil) {
        self.historyService = historyService ?? MomentHistoryService()
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

    /// Saves the completed moment to Firestore history, then clears the active plan.
    func endMoment(uid: String) {
        guard let plan = currentPlan, let startedAt = plan.startedAt else {
            currentPlan = nil
            save()
            return
        }

        let completed = CompletedMoment(
            title: plan.title,
            vibe: plan.vibe,
            playlistId: plan.playlistId,
            dishIds: plan.dishIds,
            gameNumbers: plan.gameNumbers,
            startedAt: startedAt,
            endedAt: Date()
        )

        currentPlan = nil
        save()

        Task {
            do {
                try await historyService.saveMoment(completed, uid: uid)
                // Prepend to local list so the profile updates instantly
                recentMoments.insert(completed, at: 0)
                if recentMoments.count > 10 {
                    recentMoments = Array(recentMoments.prefix(10))
                }
            } catch {
                // History save is non-critical — plan is already ended locally
            }
        }
    }

    // MARK: - Favorites (derived from history)

    /// Most-used playlist ID across all completed moments, or nil if none.
    var topPlaylistId: String? {
        mostFrequent(recentMoments.compactMap { $0.playlistId })
    }

    /// Most-used game number across all completed moments, or nil if none.
    var topGameNumber: Int? {
        mostFrequent(recentMoments.flatMap { $0.gameNumbers })
    }

    /// Most-used dish ID across all completed moments, or nil if none.
    var topDishId: String? {
        mostFrequent(recentMoments.flatMap { $0.dishIds })
    }

    private func mostFrequent<T: Hashable>(_ items: [T]) -> T? {
        guard !items.isEmpty else { return nil }
        var counts: [T: Int] = [:]
        for item in items { counts[item, default: 0] += 1 }
        return counts.max(by: { $0.value < $1.value })?.key
    }

    func fetchRecentMoments(uid: String) async {
        guard !isLoadingHistory else { return }
        isLoadingHistory = true
        do {
            recentMoments = try await historyService.fetchRecentMoments(uid: uid, limit: 10)
        } catch {
            // Non-critical; recentMoments stays empty
        }
        isLoadingHistory = false
    }

    // MARK: - Persistence (active plan only — history is in Firestore)

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
