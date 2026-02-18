import Foundation

struct Meal: Identifiable, Codable, Equatable {
    let id: UUID
    let userID: UUID
    var name: String
    var calories: Int
    var protein: Int
    var carbs: Int
    var fats: Int
    var createdAt: Date
}
