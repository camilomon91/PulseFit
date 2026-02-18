import Foundation

struct Exercise: Identifiable, Codable, Equatable {
    let id: UUID
    let workoutID: UUID
    var name: String
    var targetSets: Int
    var targetReps: Int
    var createdAt: Date
}
