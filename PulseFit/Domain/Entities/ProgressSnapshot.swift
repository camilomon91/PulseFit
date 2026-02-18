import Foundation

struct ProgressSnapshot: Identifiable, Equatable {
    let id = UUID()
    let day: String
    let workoutsCompleted: Int
    let setsCompleted: Int
    let calories: Int
    let totalVolume: Double
}
