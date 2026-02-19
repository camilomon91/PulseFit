import Foundation
import Combine

@MainActor
final class AppController: ObservableObject {
    @Published var isAuthenticated = false
    @Published var selectedTab: Int = 0
    @Published var errorMessage: String?

    let authController = AuthController()
    let workoutController = WorkoutController()
    let mealController = MealController()
    let checkInController = CheckInController()
    let progressController = ProgressController()

    init() {
        authController.onAuthStateChanged = { [weak self] isAuthenticated in
            self?.isAuthenticated = isAuthenticated
            if isAuthenticated {
                Task { await self?.refreshAll() }
            }
        }
    }

    func start() async {
        await authController.loadSession()
    }

    func refreshAll() async {
        async let workouts = workoutController.loadWorkouts()
        async let meals = mealController.loadMeals()
        async let checkInHistory = checkInController.loadHistory()
        async let logs = progressController.loadData(mealController: mealController, checkInController: checkInController)
        _ = await (workouts, meals, checkInHistory, logs)
    }
}
