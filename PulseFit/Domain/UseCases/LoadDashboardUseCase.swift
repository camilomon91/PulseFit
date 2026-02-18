import Foundation

struct LoadDashboardUseCase {
    let workouts: WorkoutRepository
    let meals: MealRepository

    func execute(userID: UUID) async throws -> (workouts: [Workout], meals: [Meal]) {
        async let ws = workouts.fetchWorkouts(userID: userID)
        async let ms = meals.fetchMeals(userID: userID)
        return try await (ws, ms)
    }
}
