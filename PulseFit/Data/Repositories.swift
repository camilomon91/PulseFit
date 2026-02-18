import Foundation

protocol SessionsRepository {
    func startSession(userID: UUID) async -> Session
    func endSession(_ sessionID: UUID) async
    func fetchActiveSession(userID: UUID) async -> Session?
    func fetchSessions(userID: UUID) async -> [Session]
    func addExercise(to sessionID: UUID, exercise: Exercise) async -> SessionExercise?
    func addSet(to sessionExerciseID: UUID) async -> WorkoutSet?
    func updateSet(_ set: WorkoutSet) async
    func suggestion(for exerciseID: UUID, userID: UUID, progressionMethod: ProgressionMethod) async -> ExerciseSuggestion
}

protocol NutritionRepository {
    func addEntry(_ entry: FoodEntry) async
    func entriesForToday(userID: UUID) async -> [FoodEntry]
    func entriesForLast7Days(userID: UUID) async -> [FoodEntry]
    func totals(for entries: [FoodEntry]) -> MacroTotals
}

protocol ExercisesRepository {
    func fetchLibrary(userID: UUID) async -> [Exercise]
}
