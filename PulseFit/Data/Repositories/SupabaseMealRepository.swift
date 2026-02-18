import Foundation
import Supabase

final class SupabaseMealRepository: MealRepository {
    private let service: SupabaseService

    init(service: SupabaseService) {
        self.service = service
    }

    func fetchMeals(userID: UUID) async throws -> [Meal] {
        let rows: [MealRow] = try await service.client
            .from("meals")
            .select()
            .eq("user_id", value: userID.uuidString)
            .execute()
            .value
        return rows.map { $0.toDomain() }
    }

    func createMeal(userID: UUID, name: String, calories: Int, protein: Int, carbs: Int, fats: Int) async throws -> Meal {
        let inserted: MealRow = try await service.client
            .from("meals")
            .insert([
                "user_id": userID.uuidString,
                "name": name,
                "calories": calories,
                "protein": protein,
                "carbs": carbs,
                "fats": fats
            ])
            .select()
            .single()
            .execute()
            .value
        return inserted.toDomain()
    }

    func updateMeal(_ meal: Meal) async throws -> Meal {
        let updated: MealRow = try await service.client
            .from("meals")
            .update([
                "name": meal.name,
                "calories": meal.calories,
                "protein": meal.protein,
                "carbs": meal.carbs,
                "fats": meal.fats
            ])
            .eq("id", value: meal.id.uuidString)
            .select()
            .single()
            .execute()
            .value
        return updated.toDomain()
    }

    func deleteMeal(mealID: UUID) async throws {
        _ = try await service.client
            .from("meals")
            .delete()
            .eq("id", value: mealID.uuidString)
            .execute()
    }

    func logMeal(userID: UUID, mealID: UUID, eatenAt: Date) async throws -> MealLog {
        let inserted: MealLogRow = try await service.client
            .from("meal_logs")
            .insert(["user_id": userID.uuidString, "meal_id": mealID.uuidString, "eaten_at": ISO8601DateFormatter().string(from: eatenAt)])
            .select()
            .single()
            .execute()
            .value
        return inserted.toDomain()
    }
}
