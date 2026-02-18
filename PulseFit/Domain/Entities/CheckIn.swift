import Foundation

struct CheckIn: Identifiable, Codable, Equatable {
    let id: UUID
    let userID: UUID
    let workoutID: UUID
    var startedAt: Date
    var endedAt: Date?
}
