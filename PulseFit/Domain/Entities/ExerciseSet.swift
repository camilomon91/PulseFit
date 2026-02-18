import Foundation

struct ExerciseSet: Identifiable, Codable, Equatable {
    let id: UUID
    let checkInID: UUID
    let exerciseID: UUID
    var setIndex: Int
    var reps: Int
    var weight: Double
    var startedAt: Date
    var endedAt: Date
    var restSecondsBeforeSet: Int

    var durationSeconds: Int {
        max(Int(endedAt.timeIntervalSince(startedAt)), 0)
    }
}
