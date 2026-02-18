import Foundation

struct WeeklyPoint: Identifiable {
    let id = UUID()
    let label: String
    let value: Int
}

@MainActor
final class ProgressViewModel: ObservableObject {
    @Published var weeklyCheckIns: [WeeklyPoint] = []
    @Published var weeklyProteinAdherence: [WeeklyPoint] = []

    private unowned let appState: AppState
    private let sessionsRepository: SessionsRepository
    private let nutritionRepository: NutritionRepository

    init(appState: AppState, sessionsRepository: SessionsRepository, nutritionRepository: NutritionRepository) {
        self.appState = appState
        self.sessionsRepository = sessionsRepository
        self.nutritionRepository = nutritionRepository
    }

    func load() async {
        let sessions = await sessionsRepository.fetchSessions(userID: appState.profile.id)
        weeklyCheckIns = aggregateByWeekday(dates: sessions.map(\.startedAt))

        let foods = await nutritionRepository.entriesForLast7Days(userID: appState.profile.id)
        let grouped = Dictionary(grouping: foods) { Calendar.current.startOfDay(for: $0.loggedAt) }
        weeklyProteinAdherence = grouped.keys.sorted().map { day in
            let totalProtein = grouped[day, default: []].reduce(0) { $0 + $1.protein }
            return WeeklyPoint(label: day.formatted(.dateTime.weekday(.abbreviated)), value: totalProtein)
        }
    }

    private func aggregateByWeekday(dates: [Date]) -> [WeeklyPoint] {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.setLocalizedDateFormatFromTemplate("EEE")

        let groups = Dictionary(grouping: dates) { formatter.string(from: $0) }
        return groups.map { WeeklyPoint(label: $0.key, value: $0.value.count) }
            .sorted { $0.label < $1.label }
    }
}
