import Foundation

@MainActor
final class AppContainer: ObservableObject {
    let authRepository: AuthRepository
    let workoutRepository: WorkoutRepository
    let mealRepository: MealRepository
    let checkInRepository: CheckInRepository

    init() {
        let service = DefaultSupabaseService.shared
        self.authRepository = SupabaseAuthRepository(service: service)
        self.workoutRepository = SupabaseWorkoutRepository(service: service)
        self.mealRepository = SupabaseMealRepository(service: service)
        self.checkInRepository = SupabaseCheckInRepository(service: service)
    }
}
