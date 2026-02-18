import Foundation

struct Workout: Identifiable, Codable, Equatable {
    let id: UUID
    let userID: UUID
    var name: String
    var notes: String?
    var createdAt: Date
    var exercises: [Exercise] = []
}
