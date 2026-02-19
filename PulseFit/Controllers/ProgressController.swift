import Foundation
import Combine

struct ProgressSnapshot {
    let workoutsCompleted: Int
    let setsLogged: Int
    let totalVolumeKg: Double
    let mealsLogged: Int
}

@MainActor
final class ProgressController: ObservableObject {
    @Published var snapshot = ProgressSnapshot(workoutsCompleted: 0, setsLogged: 0, totalVolumeKg: 0, mealsLogged: 0)
    @Published var checkInHistory: [GymCheckIn] = []
    @Published var workoutsById: [UUID: Workout] = [:]

    private let dataService = DataService()

    func loadData(mealController: MealController, checkInController: CheckInController) async {
        do {
            async let mealLogsRequest = dataService.fetchMealLogs()
            async let checkInsRequest = dataService.fetchCheckInHistory()
            async let workoutsRequest = dataService.fetchWorkouts()

            let sets = checkInController.setLogs
            let totalVolume = sets.reduce(0) { $0 + (Double($1.reps) * $1.weightKg) }

            let mealLogs = try await mealLogsRequest
            let checkIns = try await checkInsRequest
            let workouts = try await workoutsRequest

            checkInHistory = checkIns
            workoutsById = Dictionary(uniqueKeysWithValues: workouts.map { ($0.id, $0) })
            mealController.mealLogs = mealLogs

            snapshot = ProgressSnapshot(
                workoutsCompleted: checkIns.filter { $0.completedAt != nil }.count,
                setsLogged: sets.count,
                totalVolumeKg: totalVolume,
                mealsLogged: mealLogs.count
            )
        } catch {
            snapshot = ProgressSnapshot(
                workoutsCompleted: checkInController.activeCheckIn == nil ? 1 : 0,
                setsLogged: checkInController.setLogs.count,
                totalVolumeKg: checkInController.setLogs.reduce(0) { $0 + (Double($1.reps) * $1.weightKg) },
                mealsLogged: mealController.meals.count
            )
        }
    }

    func checkIns(on day: Date) -> [GymCheckIn] {
        let calendar = Calendar.current
        return checkInHistory.filter { calendar.isDate($0.startedAt, inSameDayAs: day) }
    }
}
