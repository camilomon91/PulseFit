import Foundation

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var meals: [Meal] = []
    @Published var progress: [ProgressSnapshot] = []
    @Published var errorMessage: String?

    private let loadDashboard: LoadDashboardUseCase
    private let checkIns: CheckInRepository

    init(container: AppContainer) {
        self.loadDashboard = LoadDashboardUseCase(workouts: container.workoutRepository, meals: container.mealRepository)
        self.checkIns = container.checkInRepository
    }

    func refresh(userID: UUID) async {
        do {
            let data = try await loadDashboard.execute(userID: userID)
            workouts = data.workouts
            meals = data.meals
            progress = try await checkIns.fetchProgress(
                userID: userID,
                from: Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date(),
                to: Date()
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
