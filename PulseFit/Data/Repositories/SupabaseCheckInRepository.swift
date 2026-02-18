import Foundation
import Supabase

final class SupabaseCheckInRepository: CheckInRepository {
    private let service: SupabaseService

    init(service: SupabaseService) {
        self.service = service
    }

    func startCheckIn(userID: UUID, workoutID: UUID, startedAt: Date) async throws -> CheckIn {
        let inserted: CheckInRow = try await service.client
            .from("check_ins")
            .insert([
                "user_id": userID.uuidString,
                "workout_id": workoutID.uuidString,
                "started_at": ISO8601DateFormatter().string(from: startedAt)
            ])
            .select()
            .single()
            .execute()
            .value
        return inserted.toDomain()
    }

    func finishCheckIn(checkInID: UUID, endedAt: Date) async throws {
        _ = try await service.client
            .from("check_ins")
            .update(["ended_at": ISO8601DateFormatter().string(from: endedAt)])
            .eq("id", value: checkInID.uuidString)
            .execute()
    }

    func addSet(checkInID: UUID, exerciseID: UUID, setIndex: Int, reps: Int, weight: Double, startedAt: Date, endedAt: Date, restSecondsBeforeSet: Int) async throws -> ExerciseSet {
        let inserted: ExerciseSetRow = try await service.client
            .from("exercise_sets")
            .insert([
                "check_in_id": checkInID.uuidString,
                "exercise_id": exerciseID.uuidString,
                "set_index": setIndex,
                "reps": reps,
                "weight": weight,
                "started_at": ISO8601DateFormatter().string(from: startedAt),
                "ended_at": ISO8601DateFormatter().string(from: endedAt),
                "rest_seconds_before_set": restSecondsBeforeSet
            ])
            .select()
            .single()
            .execute()
            .value
        return inserted.toDomain()
    }

    func fetchProgress(userID: UUID, from: Date, to: Date) async throws -> [ProgressSnapshot] {
        let checkIns: [CheckInRow] = try await service.client
            .from("check_ins")
            .select()
            .eq("user_id", value: userID.uuidString)
            .gte("started_at", value: ISO8601DateFormatter().string(from: from))
            .lte("started_at", value: ISO8601DateFormatter().string(from: to))
            .execute()
            .value

        let sets: [ExerciseSetRow] = try await service.client
            .from("exercise_sets")
            .select()
            .execute()
            .value

        let logs: [MealLogRow] = try await service.client
            .from("meal_logs")
            .select()
            .eq("user_id", value: userID.uuidString)
            .gte("eaten_at", value: ISO8601DateFormatter().string(from: from))
            .lte("eaten_at", value: ISO8601DateFormatter().string(from: to))
            .execute()
            .value

        let meals: [MealRow] = try await service.client
            .from("meals")
            .select()
            .eq("user_id", value: userID.uuidString)
            .execute()
            .value

        let mealByID = Dictionary(uniqueKeysWithValues: meals.map { ($0.id, $0) })
        let setsByCheckIn = Dictionary(grouping: sets, by: { $0.check_in_id })
        let logsByDay = Dictionary(grouping: logs, by: { $0.eaten_at.dayKey() })

        let checkInsByDay = Dictionary(grouping: checkIns, by: { $0.started_at.dayKey() })
        return checkInsByDay.keys.sorted().map { key in
            let dayCheckIns = checkInsByDay[key] ?? []
            let daySets = dayCheckIns.flatMap { setsByCheckIn[$0.id] ?? [] }
            let calories = (logsByDay[key] ?? []).reduce(0) { partial, log in
                partial + (mealByID[log.meal_id]?.calories ?? 0)
            }
            let volume = daySets.reduce(0.0) { $0 + (Double($1.reps) * $1.weight) }
            return ProgressSnapshot(
                day: key,
                workoutsCompleted: dayCheckIns.count,
                setsCompleted: daySets.count,
                calories: calories,
                totalVolume: volume
            )
        }
    }
}
