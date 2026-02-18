import Foundation

protocol WorkoutRepository {
    func fetchWorkouts(userID: UUID) async throws -> [Workout]
    func createWorkout(userID: UUID, name: String, notes: String?) async throws -> Workout
    func updateWorkout(_ workout: Workout) async throws -> Workout
    func deleteWorkout(workoutID: UUID) async throws

    func createExercise(workoutID: UUID, name: String, targetSets: Int, targetReps: Int) async throws -> Exercise
    func updateExercise(_ exercise: Exercise) async throws -> Exercise
    func deleteExercise(exerciseID: UUID) async throws
}
