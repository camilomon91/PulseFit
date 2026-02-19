import Foundation
import Combine

@MainActor
final class MealController: ObservableObject {
    @Published var meals: [Meal] = []
    @Published var errorMessage: String?

    private let dataService = DataService()

    func loadMeals() async {
        do {
            meals = try await dataService.fetchMeals()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addMeal(name: String, calories: Int, protein: Int, carbs: Int, fat: Int) async {
        do {
            try await dataService.createMeal(name: name, calories: calories, protein: protein, carbs: carbs, fat: fat)
            await loadMeals()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func saveMeal(_ meal: Meal) async {
        do {
            try await dataService.updateMeal(meal)
            await loadMeals()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func removeMeal(id: UUID) async {
        do {
            try await dataService.deleteMeal(id: id)
            await loadMeals()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
