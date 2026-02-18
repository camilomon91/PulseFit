import Foundation

enum Units: String, CaseIterable, Codable {
    case metric
    case imperial
}

enum TrackingType: String, CaseIterable, Codable {
    case strength
    case time
    case distanceTime
}

enum ProgressionMethod: String, CaseIterable, Codable {
    case doubleProgression
    case linear
}

struct Profile: Identifiable, Codable {
    let id: UUID
    var displayName: String
    var units: Units
    var weeklyGymGoal: Int
    var calorieGoal: Int
    var proteinGoal: Int
    var carbGoal: Int
    var fatGoal: Int
    var progressionMethod: ProgressionMethod



    func withID(_ id: UUID) -> Profile {
        Profile(id: id, displayName: displayName, units: units, weeklyGymGoal: weeklyGymGoal, calorieGoal: calorieGoal, proteinGoal: proteinGoal, carbGoal: carbGoal, fatGoal: fatGoal, progressionMethod: progressionMethod)
    }

    static let defaultProfile = Profile(
        id: UUID(),
        displayName: "Athlete",
        units: .imperial,
        weeklyGymGoal: 4,
        calorieGoal: 2500,
        proteinGoal: 180,
        carbGoal: 250,
        fatGoal: 70,
        progressionMethod: .doubleProgression
    )
}

struct Session: Identifiable, Codable {
    let id: UUID
    let userID: UUID
    let startedAt: Date
    var endedAt: Date?
    var mood: Int?
    var energy: Int?
    var notes: String?
    var exercises: [SessionExercise]

    var isActive: Bool { endedAt == nil }
    var duration: TimeInterval { (endedAt ?? .now).timeIntervalSince(startedAt) }
}

struct Exercise: Identifiable, Codable, Hashable {
    let id: UUID
    let userID: UUID
    var name: String
    var category: String
    var trackingType: TrackingType
}

struct SessionExercise: Identifiable, Codable {
    let id: UUID
    let sessionID: UUID
    let exercise: Exercise
    var orderIndex: Int
    var notes: String?
    var sets: [WorkoutSet]
}

struct WorkoutSet: Identifiable, Codable {
    let id: UUID
    let sessionExerciseID: UUID
    var setIndex: Int
    var weight: Double?
    var reps: Int?
    var timeSeconds: Int?
    var distanceMeters: Double?
    var rpe: Int?
    var isCompleted: Bool
}

struct FoodEntry: Identifiable, Codable {
    let id: UUID
    let userID: UUID
    var loggedAt: Date
    var name: String
    var calories: Int
    var protein: Int
    var carbs: Int
    var fat: Int
}

struct MacroTotals {
    var calories: Int
    var protein: Int
    var carbs: Int
    var fat: Int

    static let zero = MacroTotals(calories: 0, protein: 0, carbs: 0, fat: 0)
}

struct ExerciseSuggestion {
    var targetWeight: Double?
    var targetReps: Int?
    var reason: String
}
