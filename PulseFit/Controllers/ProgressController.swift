import Foundation

struct ProgressSnapshot {
    let workoutsCompleted: Int
    let setsLogged: Int
    let totalVolumeKg: Double
    let mealsLogged: Int
}

@MainActor
final class ProgressController: ObservableObject {
    @Published var snapshot = ProgressSnapshot(workoutsCompleted: 0, setsLogged: 0, totalVolumeKg: 0, mealsLogged: 0)

    func loadData(mealController: MealController, checkInController: CheckInController) async {
        let sets = checkInController.setLogs
        let totalVolume = sets.reduce(0) { $0 + (Double($1.reps) * $1.weightKg) }
        snapshot = ProgressSnapshot(
            workoutsCompleted: checkInController.activeCheckIn == nil ? 1 : 0,
            setsLogged: sets.count,
            totalVolumeKg: totalVolume,
            mealsLogged: mealController.meals.count
        )
    }
}
