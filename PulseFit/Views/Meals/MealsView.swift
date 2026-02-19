import SwiftUI

struct MealsView: View {
    @ObservedObject var controller: MealController
    @ObservedObject var checkInController: CheckInController

    @State private var name = ""
    @State private var calories = 500
    @State private var protein = 30
    @State private var carbs = 40
    @State private var fat = 15
    @State private var showingError = false
    @State private var loggingMealIds: Set<UUID> = []

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Create Meal") {
                    TextField("Meal name", text: $name)
                    Stepper("Calories: \(calories)", value: $calories, in: 50...2000)
                    Stepper("Protein: \(protein)g", value: $protein, in: 0...300)
                    Stepper("Carbs: \(carbs)g", value: $carbs, in: 0...300)
                    Stepper("Fat: \(fat)g", value: $fat, in: 0...150)
                    Button("Save Meal") {
                        Task {
                            await controller.addMeal(name: name, calories: calories, protein: protein, carbs: carbs, fat: fat)
                            if controller.errorMessage == nil {
                                name = ""
                            }
                        }
                    }
                    .disabled(trimmedName.isEmpty)
                }

                Section("Meals") {
                    if controller.meals.isEmpty {
                        Text("No meals yet. Add your first meal above.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(controller.meals) { meal in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(meal.name)
                                    Text("\(meal.calories) kcal · P\(meal.protein) C\(meal.carbs) F\(meal.fat)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Button(loggingMealIds.contains(meal.id) ? "Logging..." : "Log") {
                                    Task {
                                        loggingMealIds.insert(meal.id)
                                        await controller.logMeal(mealId: meal.id)
                                        if controller.errorMessage != nil {
                                            checkInController.errorMessage = controller.errorMessage
                                        }
                                        loggingMealIds.remove(meal.id)
                                    }
                                }
                                .buttonStyle(.bordered)
                                .disabled(loggingMealIds.contains(meal.id))
                            }
                        }
                        .onDelete { indexSet in
                            Task {
                                for index in indexSet {
                                    await controller.removeMeal(id: controller.meals[index].id)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Meals")
            .task { await controller.loadMeals() }
            .refreshable { await controller.loadMeals() }
            .onChange(of: controller.errorMessage) { _, newValue in
                showingError = newValue != nil
            }
            .alert("Meals Error", isPresented: $showingError, presenting: controller.errorMessage) { _ in
                Button("OK") {
                    controller.errorMessage = nil
                }
            } message: { message in
                Text(message)
            }
        }
    }
}
