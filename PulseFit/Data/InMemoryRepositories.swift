import Foundation

actor InMemorySessionsRepository: SessionsRepository {
    private let exercisesRepository: InMemoryExercisesRepository
    private var sessions: [Session] = []

    init(exercisesRepository: InMemoryExercisesRepository) {
        self.exercisesRepository = exercisesRepository
    }

    func startSession(userID: UUID) async -> Session {
        let session = Session(id: UUID(), userID: userID, startedAt: .now, endedAt: nil, mood: nil, energy: nil, notes: nil, exercises: [])
        sessions.append(session)
        return session
    }

    func endSession(_ sessionID: UUID) async {
        guard let index = sessions.firstIndex(where: { $0.id == sessionID }) else { return }
        sessions[index].endedAt = .now
    }

    func fetchActiveSession(userID: UUID) async -> Session? {
        sessions.last(where: { $0.userID == userID && $0.isActive })
    }

    func fetchSessions(userID: UUID) async -> [Session] {
        sessions.filter { $0.userID == userID }.sorted { $0.startedAt > $1.startedAt }
    }

    func addExercise(to sessionID: UUID, exercise: Exercise) async -> SessionExercise? {
        guard let sessionIndex = sessions.firstIndex(where: { $0.id == sessionID }) else { return nil }
        var sessionExercise = SessionExercise(
            id: UUID(),
            sessionID: sessionID,
            exercise: exercise,
            orderIndex: sessions[sessionIndex].exercises.count,
            notes: nil,
            sets: []
        )
        if let suggestion = await suggestion(for: exercise.id, userID: sessions[sessionIndex].userID, progressionMethod: .doubleProgression) as ExerciseSuggestion? {
            sessionExercise.notes = "Suggestion: \(suggestion.reason)"
        }
        sessions[sessionIndex].exercises.append(sessionExercise)
        return sessionExercise
    }

    func addSet(to sessionExerciseID: UUID) async -> WorkoutSet? {
        for sessionIndex in sessions.indices {
            if let exerciseIndex = sessions[sessionIndex].exercises.firstIndex(where: { $0.id == sessionExerciseID }) {
                let set = WorkoutSet(
                    id: UUID(),
                    sessionExerciseID: sessionExerciseID,
                    setIndex: sessions[sessionIndex].exercises[exerciseIndex].sets.count + 1,
                    weight: nil,
                    reps: nil,
                    timeSeconds: nil,
                    distanceMeters: nil,
                    rpe: nil,
                    isCompleted: false
                )
                sessions[sessionIndex].exercises[exerciseIndex].sets.append(set)
                return set
            }
        }
        return nil
    }

    func updateSet(_ set: WorkoutSet) async {
        for sessionIndex in sessions.indices {
            for exerciseIndex in sessions[sessionIndex].exercises.indices {
                if let setIndex = sessions[sessionIndex].exercises[exerciseIndex].sets.firstIndex(where: { $0.id == set.id }) {
                    sessions[sessionIndex].exercises[exerciseIndex].sets[setIndex] = set
                }
            }
        }
    }

    func suggestion(for exerciseID: UUID, userID: UUID, progressionMethod: ProgressionMethod) async -> ExerciseSuggestion {
        let performedSets = sessions
            .filter { $0.userID == userID }
            .flatMap(\.exercises)
            .filter { $0.exercise.id == exerciseID }
            .flatMap(\.sets)
            .filter(\.isCompleted)

        guard let bestSet = performedSets.max(by: { ($0.weight ?? 0) < ($1.weight ?? 0) }) else {
            return ExerciseSuggestion(targetWeight: 45, targetReps: 8, reason: "Start with a baseline working set")
        }

        let targetReps = bestSet.reps ?? 8
        let increment = progressionMethod == .doubleProgression && targetReps >= 8 ? 5.0 : 2.5
        let targetWeight = (bestSet.weight ?? 45) + increment
        return ExerciseSuggestion(targetWeight: targetWeight, targetReps: targetReps, reason: "Last session was completed. Try +\(String(format: "%.1f", increment))")
    }
}

actor InMemoryNutritionRepository: NutritionRepository {
    private var entries: [FoodEntry] = []

    func addEntry(_ entry: FoodEntry) async {
        entries.append(entry)
    }

    func entriesForToday(userID: UUID) async -> [FoodEntry] {
        let calendar = Calendar.current
        return entries.filter { $0.userID == userID && calendar.isDateInToday($0.loggedAt) }
    }

    func entriesForLast7Days(userID: UUID) async -> [FoodEntry] {
        guard let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: .now) else { return [] }
        return entries.filter { $0.userID == userID && $0.loggedAt >= weekAgo }
    }

    nonisolated func totals(for entries: [FoodEntry]) -> MacroTotals {
        entries.reduce(.zero) { partial, entry in
            MacroTotals(
                calories: partial.calories + entry.calories,
                protein: partial.protein + entry.protein,
                carbs: partial.carbs + entry.carbs,
                fat: partial.fat + entry.fat
            )
        }
    }
}

actor InMemoryExercisesRepository: ExercisesRepository {
    func fetchLibrary(userID: UUID) async -> [Exercise] {
        [
            Exercise(id: UUID(), userID: userID, name: "Back Squat", category: "Legs", trackingType: .strength),
            Exercise(id: UUID(), userID: userID, name: "Bench Press", category: "Push", trackingType: .strength),
            Exercise(id: UUID(), userID: userID, name: "Deadlift", category: "Pull", trackingType: .strength),
            Exercise(id: UUID(), userID: userID, name: "Treadmill Run", category: "Cardio", trackingType: .distanceTime)
        ]
    }
}
