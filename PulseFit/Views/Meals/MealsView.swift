import SwiftUI

struct MealsView: View {
    @ObservedObject var controller: MealController
    @ObservedObject var checkInController: CheckInController

    @State private var name = ""
    @State private var calories = 500
    @State private var protein = 30
    @State private var carbs = 40
    @State private var fat = 15

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
                            name = ""
                        }
                    }
                }

                Section("Meals") {
                    ForEach(controller.meals) { meal in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(meal.name)
                                Text("\(meal.calories) kcal · P\(meal.protein) C\(meal.carbs) F\(meal.fat)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button("Log") {
                                Task { await checkInController.logMeal(mealId: meal.id) }
                            }
                            .buttonStyle(.bordered)
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
            .navigationTitle("Meals")
            .task { await controller.loadMeals() }
        }
    }
}
