import Foundation

@MainActor
final class AppState: ObservableObject {
    @Published var profile: Profile
    @Published var activeSessionID: UUID?
    @Published var backendMode: String

    let sessionsRepository: SessionsRepository
    let nutritionRepository: NutritionRepository
    let exercisesRepository: ExercisesRepository

    init() {
        if let config = SupabaseConfig.fromEnvironment() {
            let client = SupabaseRESTClient(config: config)
            self.profile = Profile.defaultProfile.withID(config.userID)
            self.activeSessionID = nil
            self.backendMode = "Supabase"
            self.sessionsRepository = SupabaseSessionsRepository(client: client)
            self.nutritionRepository = SupabaseNutritionRepository(client: client)
            self.exercisesRepository = SupabaseExercisesRepository()
            return
        }

        let exercises = InMemoryExercisesRepository()
        let sessions = InMemorySessionsRepository()
        let nutrition = InMemoryNutritionRepository()

        self.profile = .defaultProfile
        self.activeSessionID = nil
        self.backendMode = "In-Memory"
        self.sessionsRepository = sessions
        self.nutritionRepository = nutrition
        self.exercisesRepository = exercises
    }
}
