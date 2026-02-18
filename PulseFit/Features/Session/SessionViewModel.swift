import Foundation

@MainActor
final class SessionViewModel: ObservableObject {
    @Published var session: Session?
    @Published var availableExercises: [Exercise] = []

    private unowned let appState: AppState
    private let sessionsRepository: SessionsRepository
    private let exercisesRepository: ExercisesRepository
    private let sessionID: UUID

    init(appState: AppState, sessionsRepository: SessionsRepository, exercisesRepository: ExercisesRepository, sessionID: UUID) {
        self.appState = appState
        self.sessionsRepository = sessionsRepository
        self.exercisesRepository = exercisesRepository
        self.sessionID = sessionID
        Task { await refresh() }
    }

    func refresh() async {
        let sessions = await sessionsRepository.fetchSessions(userID: appState.profile.id)
        session = sessions.first(where: { $0.id == sessionID })
        availableExercises = await exercisesRepository.fetchLibrary(userID: appState.profile.id)
    }

    func addExercise(_ exercise: Exercise) async {
        _ = await sessionsRepository.addExercise(to: sessionID, exercise: exercise)
        await refresh()
    }

    func deleteExercise(_ sessionExerciseID: UUID) async {
        await sessionsRepository.deleteExercise(sessionExerciseID)
        await refresh()
    }

    func addSet(sessionExerciseID: UUID) async {
        _ = await sessionsRepository.addSet(to: sessionExerciseID)
        await refresh()
    }

    func updateSet(_ set: WorkoutSet, weight: Double?, reps: Int?) async {
        var copy = set
        copy.weight = weight
        copy.reps = reps
        await sessionsRepository.updateSet(copy)
        await refresh()
    }

    func toggleSetCompleted(_ set: WorkoutSet) async {
        var copy = set
        copy.isCompleted.toggle()
        await sessionsRepository.updateSet(copy)
        await refresh()
    }

    func deleteSet(_ setID: UUID) async {
        await sessionsRepository.deleteSet(setID)
        await refresh()
    }
}
