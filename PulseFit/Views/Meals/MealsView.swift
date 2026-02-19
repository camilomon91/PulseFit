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

    private var mealsById: [UUID: Meal] {
        Dictionary(uniqueKeysWithValues: controller.meals.map { ($0.id, $0) })
    }

    private var groupedMealLogs: [(day: Date, logs: [MealLog])] {
        let grouped = Dictionary(grouping: controller.mealLogs) { Calendar.current.startOfDay(for: $0.consumedAt) }
        return grouped
            .map { ($0.key, $0.value.sorted { $0.consumedAt > $1.consumedAt }) }
            .sorted { $0.day > $1.day }
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

                Section("Eaten Meals") {
                    if groupedMealLogs.isEmpty {
                        Text("No meal history yet. Tap Log on a meal to track it.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(groupedMealLogs, id: \.day) { group in
                            DisclosureGroup(group.day.formatted(date: .abbreviated, time: .omitted)) {
                                ForEach(group.logs) { log in
                                    VStack(alignment: .leading, spacing: 4) {
                                        let meal = mealsById[log.mealId]
                                        Text(meal?.name ?? "Deleted meal")
                                            .font(.headline)
                                        Text(log.consumedAt.formatted(date: .omitted, time: .shortened))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)

                                        if let meal {
                                            Text("\(meal.calories) kcal · Protein \(meal.protein)g · Carbs \(meal.carbs)g · Fat \(meal.fat)g")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    .padding(.vertical, 4)
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
