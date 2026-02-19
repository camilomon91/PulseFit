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

    private let dataService = DataService()

    func loadData(mealController: MealController, checkInController: CheckInController) async {
        do {
            async let mealLogs = dataService.fetchMealLogs()
            async let completedCheckIns = dataService.fetchCompletedCheckInsCount()

            let sets = checkInController.setLogs
            let totalVolume = sets.reduce(0) { $0 + (Double($1.reps) * $1.weightKg) }

            let fetchedMealLogs = try await mealLogs
            let checkInCount = try await completedCheckIns

            snapshot = ProgressSnapshot(
                workoutsCompleted: checkInCount,
                setsLogged: sets.count,
                totalVolumeKg: totalVolume,
                mealsLogged: fetchedMealLogs.count
            )

            mealController.mealLogs = fetchedMealLogs
        } catch {
            snapshot = ProgressSnapshot(
                workoutsCompleted: checkInController.activeCheckIn == nil ? 1 : 0,
                setsLogged: checkInController.setLogs.count,
                totalVolumeKg: checkInController.setLogs.reduce(0) { $0 + (Double($1.reps) * $1.weightKg) },
                mealsLogged: mealController.meals.count
            )
        }
    }
}
