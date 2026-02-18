import Foundation

struct WorkoutRow: Codable {
    let id: UUID
    let user_id: UUID
    let name: String
    let notes: String?
    let created_at: Date
}

struct ExerciseRow: Codable {
    let id: UUID
    let workout_id: UUID
    let name: String
    let target_sets: Int
    let target_reps: Int
    let created_at: Date
}

struct MealRow: Codable {
    let id: UUID
    let user_id: UUID
    let name: String
    let calories: Int
    let protein: Int
    let carbs: Int
    let fats: Int
    let created_at: Date
}

struct CheckInRow: Codable {
    let id: UUID
    let user_id: UUID
    let workout_id: UUID
    let started_at: Date
    let ended_at: Date?
}

struct ExerciseSetRow: Codable {
    let id: UUID
    let check_in_id: UUID
    let exercise_id: UUID
    let set_index: Int
    let reps: Int
    let weight: Double
    let started_at: Date
    let ended_at: Date
    let rest_seconds_before_set: Int
}

struct MealLogRow: Codable {
    let id: UUID
    let user_id: UUID
    let meal_id: UUID
    let eaten_at: Date
}
