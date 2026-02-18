import SwiftUI

struct NutritionView: View {
    @StateObject var viewModel: NutritionViewModel
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            List {
                Section("Today's Macros") {
                    MacroProgressRow(name: "Calories", consumed: viewModel.totals.calories, goal: appState.profile.calorieGoal)
                    MacroProgressRow(name: "Protein", consumed: viewModel.totals.protein, goal: appState.profile.proteinGoal, emphasize: true)
                    MacroProgressRow(name: "Carbs", consumed: viewModel.totals.carbs, goal: appState.profile.carbGoal)
                    MacroProgressRow(name: "Fat", consumed: viewModel.totals.fat, goal: appState.profile.fatGoal)
                }

                Section("Quick Add") {
                    Button {
                        Task { await viewModel.quickAddProteinMeal() }
                    } label: {
                        Label("Add Quick Protein Meal", systemImage: "plus.circle.fill")
                    }
                }

                Section("Food Entries") {
                    ForEach(viewModel.entries, id: \.id) { entry in
                        VStack(alignment: .leading) {
                            Text(entry.name)
                            Text("P \(entry.protein)g · C \(entry.carbs)g · F \(entry.fat)g")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Nutrition")
            .task { await viewModel.loadToday() }
        }
    }
}
