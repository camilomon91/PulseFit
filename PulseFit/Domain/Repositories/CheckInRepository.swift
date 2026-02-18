import Foundation

protocol CheckInRepository {
    func startCheckIn(userID: UUID, workoutID: UUID, startedAt: Date) async throws -> CheckIn
    func finishCheckIn(checkInID: UUID, endedAt: Date) async throws
    func addSet(checkInID: UUID, exerciseID: UUID, setIndex: Int, reps: Int, weight: Double, startedAt: Date, endedAt: Date, restSecondsBeforeSet: Int) async throws -> ExerciseSet
    func fetchProgress(userID: UUID, from: Date, to: Date) async throws -> [ProgressSnapshot]
}
