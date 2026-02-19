import Foundation
import Supabase

final class DataService {
    private let client = SupabaseService.shared.client

    private static let iso8601: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private func userId() async throws -> UUID {
        let session = try await client.auth.session
        return session.user.id
    }

    // MARK: - Workouts

    func fetchWorkouts() async throws -> [Workout] {
        let uid = try await userId()
        return try await client
            .from("workouts")
            .select()
            .eq("user_id", value: uid)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    @discardableResult
    func createWorkout(name: String, notes: String?) async throws -> Workout {
        struct Payload: Encodable {
            let user_id: UUID
            let name: String
            let notes: String?
        }

        let uid = try await userId()
        return try await client
            .from("workouts")
            .insert(Payload(user_id: uid, name: name, notes: notes))
            .select()
            .single()
            .execute()
            .value
    }

    func updateWorkout(_ workout: Workout) async throws {
        struct Update: Encodable {
            let name: String
            let notes: String?
        }

        let uid = try await userId()
        try await client
            .from("workouts")
            .update(Update(name: workout.name, notes: workout.notes))
            .eq("id", value: workout.id)
            .eq("user_id", value: uid)
            .execute()
    }

    func deleteWorkout(id: UUID) async throws {
        let uid = try await userId()
        try await client
            .from("workouts")
            .delete()
            .eq("id", value: id)
            .eq("user_id", value: uid)
            .execute()
    }

    // MARK: - Exercises

    func fetchExercises(workoutId: UUID) async throws -> [Exercise] {
        try await client
            .from("exercises")
            .select()
            .eq("workout_id", value: workoutId)
            .order("sort_order", ascending: true)
            .execute()
            .value
    }

    /// NOTE: Still client-side sort_order; for concurrency-safe ordering, move to an RPC.
    @discardableResult
    func addExercise(workoutId: UUID, name: String, targetSets: Int, targetReps: Int) async throws -> Exercise {
        struct Payload: Encodable {
            let workout_id: UUID
            let name: String
            let target_sets: Int
            let target_reps: Int
            let sort_order: Int
        }

        let current = try await fetchExercises(workoutId: workoutId)
        let payload = Payload(
            workout_id: workoutId,
            name: name,
            target_sets: targetSets,
            target_reps: targetReps,
            sort_order: current.count
        )

        return try await client
            .from("exercises")
            .insert(payload)
            .select()
            .single()
            .execute()
            .value
    }

    func updateExercise(_ exercise: Exercise) async throws {
        struct Update: Encodable {
            let name: String
            let target_sets: Int
            let target_reps: Int
            let notes: String?
            let sort_order: Int
        }

        try await client
            .from("exercises")
            .update(Update(
                name: exercise.name,
                target_sets: exercise.targetSets,
                target_reps: exercise.targetReps,
                notes: exercise.notes,
                sort_order: exercise.sortOrder
            ))
            .eq("id", value: exercise.id)
            .execute()
    }

    func deleteExercise(id: UUID) async throws {
        try await client
            .from("exercises")
            .delete()
            .eq("id", value: id)
            .execute()
    }

    // MARK: - Meals

    func fetchMeals() async throws -> [Meal] {
        let uid = try await userId()
        return try await client
            .from("meals")
            .select()
            .eq("user_id", value: uid)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    @discardableResult
    func createMeal(name: String, calories: Int, protein: Int, carbs: Int, fat: Int) async throws -> Meal {
        struct Payload: Encodable {
            let user_id: UUID
            let name: String
            let calories: Int
            let protein: Int
            let carbs: Int
            let fat: Int
        }

        let uid = try await userId()
        return try await client
            .from("meals")
            .insert(Payload(
                user_id: uid,
                name: name,
                calories: calories,
                protein: protein,
                carbs: carbs,
                fat: fat
            ))
            .select()
            .single()
            .execute()
            .value
    }

    func updateMeal(_ meal: Meal) async throws {
        struct Update: Encodable {
            let name: String
            let calories: Int
            let protein: Int
            let carbs: Int
            let fat: Int
        }

        let uid = try await userId()
        try await client
            .from("meals")
            .update(Update(
                name: meal.name,
                calories: meal.calories,
                protein: meal.protein,
                carbs: meal.carbs,
                fat: meal.fat
            ))
            .eq("id", value: meal.id)
            .eq("user_id", value: uid)
            .execute()
    }

    func deleteMeal(id: UUID) async throws {
        let uid = try await userId()
        try await client
            .from("meals")
            .delete()
            .eq("id", value: id)
            .eq("user_id", value: uid)
            .execute()
    }

    // MARK: - Check-ins and logs

    @discardableResult
    func createCheckIn(workoutId: UUID) async throws -> GymCheckIn {
        struct Payload: Encodable {
            let user_id: UUID
            let workout_id: UUID
        }

        let uid = try await userId()
        return try await client
            .from("gym_check_ins")
            .insert(Payload(user_id: uid, workout_id: workoutId))
            .select()
            .single()
            .execute()
            .value
    }

    func finishCheckIn(checkInId: UUID) async throws {
        let completedAt = Self.iso8601.string(from: Date())
        try await client
            .from("gym_check_ins")
            .update(["completed_at": completedAt])
            .eq("id", value: checkInId)
            .execute()
    }

    @discardableResult
    func logSet(
        checkInId: UUID,
        exerciseId: UUID,
        setNumber: Int,
        reps: Int,
        weightKg: Double,
        startedAt: Date,
        completedAt: Date,
        restSeconds: Int
    ) async throws -> ExerciseSetLog {
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

        let payload = Payload(
            check_in_id: checkInId,
            exercise_id: exerciseId,
            set_number: setNumber,
            reps: reps,
            weight_kg: weightKg,
            started_at: Self.iso8601.string(from: startedAt),
            completed_at: Self.iso8601.string(from: completedAt),
            rest_seconds: restSeconds
        )

        return try await client
            .from("exercise_set_logs")
            .insert(payload)
            .select()
            .single()
            .execute()
            .value
    }

    func fetchSetLogs(checkInId: UUID) async throws -> [ExerciseSetLog] {
        try await client
            .from("exercise_set_logs")
            .select()
            .eq("check_in_id", value: checkInId)
            .order("set_number", ascending: true)
            .execute()
            .value
    }

    func logMealConsumption(mealId: UUID, consumedAt: Date = Date()) async throws {
        struct Payload: Encodable {
            let user_id: UUID
            let meal_id: UUID
            let consumed_at: String
        }

        let uid = try await userId()
        try await client
            .from("meal_logs")
            .insert(Payload(
                user_id: uid,
                meal_id: mealId,
                consumed_at: Self.iso8601.string(from: consumedAt)
            ))
            .execute()
    }

    func fetchMealLogs() async throws -> [MealLog] {
        let uid = try await userId()
        return try await client
            .from("meal_logs")
            .select()
            .eq("user_id", value: uid)
            .order("consumed_at", ascending: false)
            .execute()
            .value
    }
}
