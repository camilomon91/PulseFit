import Foundation

struct MealLog: Identifiable, Codable, Equatable {
    let id: UUID
    let userID: UUID
    let mealID: UUID
    var eatenAt: Date
}
