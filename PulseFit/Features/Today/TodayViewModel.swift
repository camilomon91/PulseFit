import Foundation

@MainActor
final class TodayViewModel: ObservableObject {
    @Published var activeSession: Session?
    @Published var todayMacros: MacroTotals = .zero
    @Published var checkInStreak: Int = 0

    private unowned let appState: AppState
    private let sessionsRepository: SessionsRepository
    private let nutritionRepository: NutritionRepository

    init(appState: AppState, sessionsRepository: SessionsRepository, nutritionRepository: NutritionRepository) {
        self.appState = appState
        self.sessionsRepository = sessionsRepository
        self.nutritionRepository = nutritionRepository

        Task { await refresh() }
    }

    func refresh() async {
        activeSession = await sessionsRepository.fetchActiveSession(userID: appState.profile.id)
        appState.activeSessionID = activeSession?.id

        let todayEntries = await nutritionRepository.entriesForToday(userID: appState.profile.id)
        todayMacros = nutritionRepository.totals(for: todayEntries)

        let sessions = await sessionsRepository.fetchSessions(userID: appState.profile.id)
        checkInStreak = computeStreak(sessions: sessions)
    }

    func checkInOrEndSession() async {
        if let activeSession {
            await sessionsRepository.endSession(activeSession.id)
        } else {
            _ = await sessionsRepository.startSession(userID: appState.profile.id)
        }
        await refresh()
    }

    private func computeStreak(sessions: [Session]) -> Int {
        let calendar = Calendar.current
        let days = Set(sessions.map { calendar.startOfDay(for: $0.startedAt) })
        var streak = 0
        var cursor = calendar.startOfDay(for: .now)

        while days.contains(cursor) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }
        return streak
    }
}
