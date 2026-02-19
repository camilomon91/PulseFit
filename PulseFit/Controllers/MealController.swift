import Foundation
import Combine

struct MacroSummary {
    let calories: Int
    let protein: Int
    let carbs: Int
    let fat: Int
}

@MainActor
final class MealController: ObservableObject {
    @Published var meals: [Meal] = []
    @Published var mealLogs: [MealLog] = []
    @Published var errorMessage: String?
    @Published var isLoading = false

    private let dataService = DataService()

    func loadMeals() async {
        isLoading = true
        defer { isLoading = false }

        do {
            async let mealsRequest = dataService.fetchMeals()
            async let logsRequest = dataService.fetchMealLogs()
            meals = try await mealsRequest
            mealLogs = try await logsRequest
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addMeal(name: String, calories: Int, protein: Int, carbs: Int, fat: Int) async {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            errorMessage = "Meal name can't be empty."
            return
        }

        guard calories >= 0, protein >= 0, carbs >= 0, fat >= 0 else {
            errorMessage = "Meal values cannot be negative."
            return
        }

        do {
            let createdMeal = try await dataService.createMeal(
                name: trimmedName,
                calories: calories,
                protein: protein,
                carbs: carbs,
                fat: fat
            )
            meals.insert(createdMeal, at: 0)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func saveMeal(_ meal: Meal) async {
        do {
            try await dataService.updateMeal(meal)
            if let index = meals.firstIndex(where: { $0.id == meal.id }) {
                meals[index] = meal
            }
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func removeMeal(id: UUID) async {
        do {
            try await dataService.deleteMeal(id: id)
            meals.removeAll { $0.id == id }
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func logMeal(mealId: UUID) async {
        do {
            try await dataService.logMealConsumption(mealId: mealId)
            mealLogs = try await dataService.fetchMealLogs()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func logsForToday() -> [MealLog] {
        let calendar = Calendar.current
        return mealLogs.filter { calendar.isDateInToday($0.consumedAt) }
    }

    func macroSummary(for logs: [MealLog]) -> MacroSummary {
        let mealsById = Dictionary(uniqueKeysWithValues: meals.map { ($0.id, $0) })

        let totals = logs.reduce((calories: 0, protein: 0, carbs: 0, fat: 0)) { partial, log in
            guard let meal = mealsById[log.mealId] else { return partial }
            return (
                calories: partial.calories + meal.calories,
                protein: partial.protein + meal.protein,
                carbs: partial.carbs + meal.carbs,
                fat: partial.fat + meal.fat
            )
        }

        return MacroSummary(
            calories: totals.calories,
            protein: totals.protein,
            carbs: totals.carbs,
            fat: totals.fat
        )
    }
}
