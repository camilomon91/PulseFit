import Foundation
import Supabase

final class SupabaseWorkoutRepository: WorkoutRepository {
    private let service: SupabaseService

    init(service: SupabaseService) {
        self.service = service
    }

    func fetchWorkouts(userID: UUID) async throws -> [Workout] {
        let workoutRows: [WorkoutRow] = try await service.client
            .from("workouts")
            .select()
            .eq("user_id", value: userID.uuidString)
            .execute()
            .value

        let exerciseRows: [ExerciseRow] = try await service.client
            .from("exercises")
            .select()
            .execute()
            .value

        let grouped = Dictionary(grouping: exerciseRows.map { $0.toDomain() }, by: { $0.workoutID })
        return workoutRows.map { $0.toDomain(exercises: grouped[$0.id] ?? []) }
    }

    func createWorkout(userID: UUID, name: String, notes: String?) async throws -> Workout {
        let inserted: WorkoutRow = try await service.client
            .from("workouts")
            .insert(["user_id": userID.uuidString, "name": name, "notes": notes as Any])
            .select()
            .single()
            .execute()
            .value
        return inserted.toDomain(exercises: [])
    }

    func updateWorkout(_ workout: Workout) async throws -> Workout {
        let updated: WorkoutRow = try await service.client
            .from("workouts")
            .update(["name": workout.name, "notes": workout.notes as Any])
            .eq("id", value: workout.id.uuidString)
            .select()
            .single()
            .execute()
            .value
        return updated.toDomain(exercises: workout.exercises)
    }

    func deleteWorkout(workoutID: UUID) async throws {
        _ = try await service.client
            .from("workouts")
            .delete()
            .eq("id", value: workoutID.uuidString)
            .execute()
    }

    func createExercise(workoutID: UUID, name: String, targetSets: Int, targetReps: Int) async throws -> Exercise {
        let inserted: ExerciseRow = try await service.client
            .from("exercises")
            .insert(["workout_id": workoutID.uuidString, "name": name, "target_sets": targetSets, "target_reps": targetReps])
            .select()
            .single()
            .execute()
            .value
        return inserted.toDomain()
    }

    func updateExercise(_ exercise: Exercise) async throws -> Exercise {
        let updated: ExerciseRow = try await service.client
            .from("exercises")
            .update(["name": exercise.name, "target_sets": exercise.targetSets, "target_reps": exercise.targetReps])
            .eq("id", value: exercise.id.uuidString)
            .select()
            .single()
            .execute()
            .value
        return updated.toDomain()
    }

    func deleteExercise(exerciseID: UUID) async throws {
        _ = try await service.client
            .from("exercises")
            .delete()
            .eq("id", value: exerciseID.uuidString)
            .execute()
    }
}
