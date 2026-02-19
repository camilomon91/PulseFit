import Foundation

struct AppUser: Codable, Identifiable {
    let id: UUID
    let email: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case createdAt = "created_at"
    }
}

struct Workout: Codable, Identifiable, Hashable {
    let id: UUID
    let userId: UUID
    var name: String
    var notes: String?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case notes
        case createdAt = "created_at"
    }
}

struct Exercise: Codable, Identifiable, Hashable {
    let id: UUID
    let workoutId: UUID
    var name: String
    var targetSets: Int
    var targetReps: Int
    var notes: String?
    var sortOrder: Int

    enum CodingKeys: String, CodingKey {
        case id
        case workoutId = "workout_id"
        case name
        case targetSets = "target_sets"
        case targetReps = "target_reps"
        case notes
        case sortOrder = "sort_order"
    }
}

struct Meal: Codable, Identifiable, Hashable {
    let id: UUID
    let userId: UUID
    var name: String
    var calories: Int
    var protein: Int
    var carbs: Int
    var fat: Int
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case calories
        case protein
        case carbs
        case fat
        case createdAt = "created_at"
    }
}

struct GymCheckIn: Codable, Identifiable, Hashable {
    let id: UUID
    let userId: UUID
    var workoutId: UUID
    let startedAt: Date
    var completedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case workoutId = "workout_id"
        case startedAt = "started_at"
        case completedAt = "completed_at"
    }
}

struct ExerciseSetLog: Codable, Identifiable, Hashable {
    let id: UUID
    let checkInId: UUID
    let exerciseId: UUID
    var setNumber: Int
    var reps: Int
    var weightKg: Double
    var startedAt: Date
    var completedAt: Date
    var restSeconds: Int

    enum CodingKeys: String, CodingKey {
        case id
        case checkInId = "check_in_id"
        case exerciseId = "exercise_id"
        case setNumber = "set_number"
        case reps
        case weightKg = "weight_kg"
        case startedAt = "started_at"
        case completedAt = "completed_at"
        case restSeconds = "rest_seconds"
    }

    var setDurationSeconds: Int {
        max(0, Int(completedAt.timeIntervalSince(startedAt)))
    }
}

struct MealLog: Codable, Identifiable, Hashable {
    let id: UUID
    let userId: UUID
    let mealId: UUID
    let consumedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case mealId = "meal_id"
        case consumedAt = "consumed_at"
    }
}
