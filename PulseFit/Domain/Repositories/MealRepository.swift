import Foundation

protocol MealRepository {
    func fetchMeals(userID: UUID) async throws -> [Meal]
    func createMeal(userID: UUID, name: String, calories: Int, protein: Int, carbs: Int, fats: Int) async throws -> Meal
    func updateMeal(_ meal: Meal) async throws -> Meal
    func deleteMeal(mealID: UUID) async throws
    func logMeal(userID: UUID, mealID: UUID, eatenAt: Date) async throws -> MealLog
}
