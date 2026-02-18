import Foundation

@MainActor
final class AppState: ObservableObject {
    @Published var profile: Profile
    @Published var activeSessionID: UUID?

    let sessionsRepository: SessionsRepository
    let nutritionRepository: NutritionRepository
    let exercisesRepository: ExercisesRepository

    init() {
        let exercises = InMemoryExercisesRepository()
        let sessions = InMemorySessionsRepository(exercisesRepository: exercises)
        let nutrition = InMemoryNutritionRepository()

        self.profile = .defaultProfile
        self.activeSessionID = nil
        self.sessionsRepository = sessions
        self.nutritionRepository = nutrition
        self.exercisesRepository = exercises
    }
}
