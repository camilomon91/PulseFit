import Foundation

@MainActor
final class CheckInViewModel: ObservableObject {
    @Published var activeCheckIn: CheckIn?
    @Published var selectedWorkoutID: UUID?
    @Published var setsByExercise: [UUID: [ExerciseSet]] = [:]
    @Published var errorMessage: String?

    private var lastSetEndByExercise: [UUID: Date] = [:]
    private let checkIns: CheckInRepository

    init(container: AppContainer) {
        self.checkIns = container.checkInRepository
    }

    func start(userID: UUID, workoutID: UUID) async {
        do {
            selectedWorkoutID = workoutID
            activeCheckIn = try await checkIns.startCheckIn(userID: userID, workoutID: workoutID, startedAt: Date())
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func finish() async {
        guard let id = activeCheckIn?.id else { return }
        do {
            try await checkIns.finishCheckIn(checkInID: id, endedAt: Date())
            activeCheckIn = nil
            lastSetEndByExercise = [:]
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func completeSet(exerciseID: UUID, reps: Int, weight: Double, start: Date, end: Date) async {
        guard let checkIn = activeCheckIn else { return }
        let current = setsByExercise[exerciseID] ?? []
        let lastEnd = lastSetEndByExercise[exerciseID] ?? checkIn.startedAt
        let rest = max(Int(start.timeIntervalSince(lastEnd)), 0)

        do {
            let created = try await checkIns.addSet(
                checkInID: checkIn.id,
                exerciseID: exerciseID,
                setIndex: current.count + 1,
                reps: reps,
                weight: weight,
                startedAt: start,
                endedAt: end,
                restSecondsBeforeSet: rest
            )
            setsByExercise[exerciseID, default: []].append(created)
            lastSetEndByExercise[exerciseID] = end
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
