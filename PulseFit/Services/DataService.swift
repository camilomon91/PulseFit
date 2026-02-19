import Foundation
import Supabase

final class DataService {
    private let client = SupabaseService.shared.client

    private func userId() async throws -> UUID {
        let session = try await client.auth.session
        return session.user.id
    }

    // MARK: Workouts
    func fetchWorkouts() async throws -> [Workout] {
        let uid = try await userId()
        return try await client.database
            .from("workouts")
            .select()
            .eq("user_id", value: uid)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func createWorkout(name: String, notes: String?) async throws {
        struct Payload: Encodable { let user_id: UUID; let name: String; let notes: String? }
        try await client.database.from("workouts").insert(Payload(user_id: try await userId(), name: name, notes: notes)).execute()
    }

    func updateWorkout(_ workout: Workout) async throws {
        try await client.database
            .from("workouts")
            .update(["name": workout.name, "notes": workout.notes as Any])
            .eq("id", value: workout.id)
            .execute()
    }

    func deleteWorkout(id: UUID) async throws {
        try await client.database.from("workouts").delete().eq("id", value: id).execute()
    }

    func fetchExercises(workoutId: UUID) async throws -> [Exercise] {
        try await client.database
            .from("exercises")
            .select()
            .eq("workout_id", value: workoutId)
            .order("sort_order", ascending: true)
            .execute()
            .value
    }

    func addExercise(workoutId: UUID, name: String, targetSets: Int, targetReps: Int) async throws {
        struct Payload: Encodable {
            let workout_id: UUID
            let name: String
            let target_sets: Int
            let target_reps: Int
            let sort_order: Int
        }
        let current = try await fetchExercises(workoutId: workoutId)
        try await client.database.from("exercises").insert(
            Payload(workout_id: workoutId, name: name, target_sets: targetSets, target_reps: targetReps, sort_order: current.count)
        ).execute()
    }

    func updateExercise(_ exercise: Exercise) async throws {
        try await client.database
            .from("exercises")
            .update([
                "name": exercise.name,
                "target_sets": exercise.targetSets,
                "target_reps": exercise.targetReps,
                "notes": exercise.notes as Any,
                "sort_order": exercise.sortOrder
            ])
            .eq("id", value: exercise.id)
            .execute()
    }

    func deleteExercise(id: UUID) async throws {
        try await client.database.from("exercises").delete().eq("id", value: id).execute()
    }

    // MARK: Meals
    func fetchMeals() async throws -> [Meal] {
        let uid = try await userId()
        return try await client.database.from("meals").select().eq("user_id", value: uid).order("created_at", ascending: false).execute().value
    }

    func createMeal(name: String, calories: Int, protein: Int, carbs: Int, fat: Int) async throws {
        struct Payload: Encodable {
            let user_id: UUID
            let name: String
            let calories: Int
            let protein: Int
            let carbs: Int
            let fat: Int
        }
        try await client.database.from("meals").insert(Payload(user_id: try await userId(), name: name, calories: calories, protein: protein, carbs: carbs, fat: fat)).execute()
    }

    func updateMeal(_ meal: Meal) async throws {
        try await client.database
            .from("meals")
            .update(["name": meal.name, "calories": meal.calories, "protein": meal.protein, "carbs": meal.carbs, "fat": meal.fat])
            .eq("id", value: meal.id)
            .execute()
    }

    func deleteMeal(id: UUID) async throws {
        try await client.database.from("meals").delete().eq("id", value: id).execute()
    }

    // MARK: Check-ins and logs
    func createCheckIn(workoutId: UUID) async throws -> GymCheckIn {
        struct Payload: Encodable { let user_id: UUID; let workout_id: UUID }
        return try await client.database
            .from("gym_check_ins")
            .insert(Payload(user_id: try await userId(), workout_id: workoutId))
            .select()
            .single()
            .execute()
            .value
    }

    func finishCheckIn(checkInId: UUID) async throws {
        try await client.database
            .from("gym_check_ins")
            .update(["completed_at": ISO8601DateFormatter().string(from: Date())])
            .eq("id", value: checkInId)
            .execute()
    }

    func logSet(checkInId: UUID, exerciseId: UUID, setNumber: Int, reps: Int, weightKg: Double, startedAt: Date, completedAt: Date, restSeconds: Int) async throws {
        struct Payload: Encodable {
            let check_in_id: UUID
            let exercise_id: UUID
            let set_number: Int
            let reps: Int
            let weight_kg: Double
            let started_at: String
            let completed_at: String
            let rest_seconds: Int
        }
        let formatter = ISO8601DateFormatter()
        try await client.database.from("exercise_set_logs").insert(
            Payload(
                check_in_id: checkInId,
                exercise_id: exerciseId,
                set_number: setNumber,
                reps: reps,
                weight_kg: weightKg,
                started_at: formatter.string(from: startedAt),
                completed_at: formatter.string(from: completedAt),
                rest_seconds: restSeconds
            )
        ).execute()
    }

    func fetchSetLogs(checkInId: UUID) async throws -> [ExerciseSetLog] {
        try await client.database.from("exercise_set_logs").select().eq("check_in_id", value: checkInId).order("set_number", ascending: true).execute().value
    }

    func logMealConsumption(mealId: UUID, consumedAt: Date = Date()) async throws {
        struct Payload: Encodable { let user_id: UUID; let meal_id: UUID; let consumed_at: String }
        try await client.database.from("meal_logs").insert(
            Payload(user_id: try await userId(), meal_id: mealId, consumed_at: ISO8601DateFormatter().string(from: consumedAt))
        ).execute()
    }

    func fetchMealLogs() async throws -> [MealLog] {
        let uid = try await userId()
        return try await client.database.from("meal_logs").select().eq("user_id", value: uid).order("consumed_at", ascending: false).execute().value
    }
}
