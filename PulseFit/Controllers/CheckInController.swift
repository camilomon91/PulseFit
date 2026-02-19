import Foundation
import Combine

@MainActor
final class CheckInController: ObservableObject {
    @Published var activeCheckIn: GymCheckIn?
    @Published var setLogs: [ExerciseSetLog] = []
    @Published var setStartTimes: [UUID: Date] = [:]
    @Published var lastSetCompletionByExercise: [UUID: Date] = [:]
    @Published var errorMessage: String?

    private let dataService = DataService()

    func startCheckIn(workoutId: UUID) async {
        do {
            activeCheckIn = try await dataService.createCheckIn(workoutId: workoutId)
            setLogs = []
            setStartTimes = [:]
            lastSetCompletionByExercise = [:]
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func beginSet(exerciseId: UUID) {
        setStartTimes[exerciseId] = Date()
    }

    func completeSet(exerciseId: UUID, setNumber: Int, reps: Int, weightKg: Double) async {
        guard let checkInId = activeCheckIn?.id else { return }
        let startedAt = setStartTimes[exerciseId] ?? Date()
        let completedAt = Date()
        let rest = Int(completedAt.timeIntervalSince(lastSetCompletionByExercise[exerciseId] ?? startedAt))

        do {
            try await dataService.logSet(
                checkInId: checkInId,
                exerciseId: exerciseId,
                setNumber: setNumber,
                reps: reps,
                weightKg: weightKg,
                startedAt: startedAt,
                completedAt: completedAt,
                restSeconds: max(rest, 0)
            )
            lastSetCompletionByExercise[exerciseId] = completedAt
            setLogs = try await dataService.fetchSetLogs(checkInId: checkInId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func finishCheckIn() async {
        guard let checkInId = activeCheckIn?.id else { return }
        do {
            try await dataService.finishCheckIn(checkInId: checkInId)
            activeCheckIn = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func logMeal(mealId: UUID) async {
        do {
            try await dataService.logMealConsumption(mealId: mealId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadSetLogs(checkInId: UUID) async {
        do {
            setLogs = try await dataService.fetchSetLogs(checkInId: checkInId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
