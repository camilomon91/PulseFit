import Foundation
import Combine

@MainActor
final class NutritionViewModel: ObservableObject {
    @Published var entries: [FoodEntry] = []
    @Published var totals: MacroTotals = .zero

    private unowned let appState: AppState
    private let nutritionRepository: NutritionRepository

    init(appState: AppState, nutritionRepository: NutritionRepository) {
        self.appState = appState
        self.nutritionRepository = nutritionRepository
    }

    func loadToday() async {
        entries = await nutritionRepository.entriesForToday(userID: appState.profile.id)
        totals = nutritionRepository.totals(for: entries)
    }

    func quickAddProteinMeal() async {
        let entry = FoodEntry(
            id: UUID(),
            userID: appState.profile.id,
            loggedAt: .now,
            name: "Quick Protein Meal",
            calories: 450,
            protein: 40,
            carbs: 35,
            fat: 15
        )
        await nutritionRepository.addEntry(entry)
        await loadToday()
    }
}
