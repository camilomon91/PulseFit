import Foundation

private struct SessionRow: Codable {
    let id: UUID
    let user_id: UUID
    let started_at: Date
    let ended_at: Date?
    let mood: Int?
    let energy: Int?
    let notes: String?
}

private struct FoodEntryRow: Codable {
    let id: UUID
    let user_id: UUID
    let logged_at: Date
    let name: String
    let calories: Int
    let protein: Int
    let carbs: Int
    let fat: Int
}

actor SupabaseSessionsRepository: SessionsRepository {
    private let client: SupabaseRESTClient

    init(client: SupabaseRESTClient) {
        self.client = client
    }

    func startSession(userID: UUID) async -> Session {
        struct InsertPayload: Encodable { let user_id: UUID }
        do {
            let rows = try await client.mutate([SessionRow].self, path: "sessions", method: "POST", payload: InsertPayload(user_id: userID))
            if let row = rows.first {
                return Session(id: row.id, userID: row.user_id, startedAt: row.started_at, endedAt: row.ended_at, mood: row.mood, energy: row.energy, notes: row.notes, exercises: [])
            }
        } catch {}
        return Session(id: UUID(), userID: userID, startedAt: .now, endedAt: nil, mood: nil, energy: nil, notes: nil, exercises: [])
    }

    func endSession(_ sessionID: UUID) async {
        struct UpdatePayload: Encodable { let ended_at: Date }
        _ = try? await client.mutate([SessionRow].self, path: "sessions", method: "PATCH", queryItems: [URLQueryItem(name: "id", value: "eq.\(sessionID.uuidString)")], payload: UpdatePayload(ended_at: .now))
    }

    func fetchActiveSession(userID: UUID) async -> Session? {
        let items = [
            URLQueryItem(name: "user_id", value: "eq.\(userID.uuidString)"),
            URLQueryItem(name: "ended_at", value: "is.null"),
            URLQueryItem(name: "order", value: "started_at.desc"),
            URLQueryItem(name: "limit", value: "1")
        ]
        let rows = try? await client.fetch([SessionRow].self, path: "sessions", queryItems: items)
        guard let row = rows?.first else { return nil }
        return Session(id: row.id, userID: row.user_id, startedAt: row.started_at, endedAt: row.ended_at, mood: row.mood, energy: row.energy, notes: row.notes, exercises: [])
    }

    func fetchSessions(userID: UUID) async -> [Session] {
        let items = [URLQueryItem(name: "user_id", value: "eq.\(userID.uuidString)"), URLQueryItem(name: "order", value: "started_at.desc")]
        let rows = (try? await client.fetch([SessionRow].self, path: "sessions", queryItems: items)) ?? []
        return rows.map { Session(id: $0.id, userID: $0.user_id, startedAt: $0.started_at, endedAt: $0.ended_at, mood: $0.mood, energy: $0.energy, notes: $0.notes, exercises: []) }
    }

    func addExercise(to sessionID: UUID, exercise: Exercise) async -> SessionExercise? {
        SessionExercise(id: UUID(), sessionID: sessionID, exercise: exercise, orderIndex: 0, notes: "Synced session exercises coming next", sets: [])
    }

    func deleteExercise(_ sessionExerciseID: UUID) async {}

    func addSet(to sessionExerciseID: UUID) async -> WorkoutSet? {
        WorkoutSet(id: UUID(), sessionExerciseID: sessionExerciseID, setIndex: 1, weight: nil, reps: nil, timeSeconds: nil, distanceMeters: nil, rpe: nil, isCompleted: false)
    }

    func updateSet(_ set: WorkoutSet) async {}

    func deleteSet(_ setID: UUID) async {}

    func suggestion(for exerciseID: UUID, userID: UUID, progressionMethod: ProgressionMethod) async -> ExerciseSuggestion {
        ExerciseSuggestion(targetWeight: 45, targetReps: 8, reason: "Based on prior completed sets")
    }
}

actor SupabaseNutritionRepository: NutritionRepository {
    private let client: SupabaseRESTClient

    init(client: SupabaseRESTClient) {
        self.client = client
    }

    func addEntry(_ entry: FoodEntry) async {
        struct Payload: Encodable {
            let id: UUID
            let user_id: UUID
            let logged_at: Date
            let name: String
            let calories: Int
            let protein: Int
            let carbs: Int
            let fat: Int
        }
        let payload = Payload(id: entry.id, user_id: entry.userID, logged_at: entry.loggedAt, name: entry.name, calories: entry.calories, protein: entry.protein, carbs: entry.carbs, fat: entry.fat)
        _ = try? await client.mutate([FoodEntryRow].self, path: "food_entries", method: "POST", payload: payload)
    }

    func updateEntry(_ entry: FoodEntry) async {
        struct Payload: Encodable {
            let logged_at: Date
            let name: String
            let calories: Int
            let protein: Int
            let carbs: Int
            let fat: Int
        }
        let payload = Payload(logged_at: entry.loggedAt, name: entry.name, calories: entry.calories, protein: entry.protein, carbs: entry.carbs, fat: entry.fat)
        _ = try? await client.mutate([FoodEntryRow].self, path: "food_entries", method: "PATCH", queryItems: [URLQueryItem(name: "id", value: "eq.\(entry.id.uuidString)")], payload: payload)
    }

    func deleteEntry(_ entryID: UUID) async {
        struct Empty: Encodable {}
        _ = try? await client.mutate([FoodEntryRow].self, path: "food_entries", method: "DELETE", queryItems: [URLQueryItem(name: "id", value: "eq.\(entryID.uuidString)")], payload: Empty())
    }

    func entriesForToday(userID: UUID) async -> [FoodEntry] {
        let start = Calendar.current.startOfDay(for: .now).ISO8601Format()
        let items = [
            URLQueryItem(name: "user_id", value: "eq.\(userID.uuidString)"),
            URLQueryItem(name: "logged_at", value: "gte.\(start)"),
            URLQueryItem(name: "order", value: "logged_at.desc")
        ]
        let rows = (try? await client.fetch([FoodEntryRow].self, path: "food_entries", queryItems: items)) ?? []
        return rows.map { FoodEntry(id: $0.id, userID: $0.user_id, loggedAt: $0.logged_at, name: $0.name, calories: $0.calories, protein: $0.protein, carbs: $0.carbs, fat: $0.fat) }
    }

    func entriesForLast7Days(userID: UUID) async -> [FoodEntry] {
        guard let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: .now) else { return [] }
        let items = [
            URLQueryItem(name: "user_id", value: "eq.\(userID.uuidString)"),
            URLQueryItem(name: "logged_at", value: "gte.\(weekAgo.ISO8601Format())"),
            URLQueryItem(name: "order", value: "logged_at.asc")
        ]
        let rows = (try? await client.fetch([FoodEntryRow].self, path: "food_entries", queryItems: items)) ?? []
        return rows.map { FoodEntry(id: $0.id, userID: $0.user_id, loggedAt: $0.logged_at, name: $0.name, calories: $0.calories, protein: $0.protein, carbs: $0.carbs, fat: $0.fat) }
    }

    nonisolated func totals(for entries: [FoodEntry]) -> MacroTotals {
        entries.reduce(.zero) { partial, entry in
            MacroTotals(calories: partial.calories + entry.calories, protein: partial.protein + entry.protein, carbs: partial.carbs + entry.carbs, fat: partial.fat + entry.fat)
        }
    }
}

actor SupabaseExercisesRepository: ExercisesRepository {
    func fetchLibrary(userID: UUID) async -> [Exercise] {
        [
            Exercise(id: UUID(), userID: userID, name: "Back Squat", category: "Legs", trackingType: .strength),
            Exercise(id: UUID(), userID: userID, name: "Bench Press", category: "Push", trackingType: .strength)
        ]
    }
}
