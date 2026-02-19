import SwiftUI

struct MealsView: View {
    @ObservedObject var controller: MealController
    @ObservedObject var checkInController: CheckInController

    @State private var name = ""
    @State private var caloriesText = "500"
    @State private var proteinText = "30"
    @State private var carbsText = "40"
    @State private var fatText = "15"
    @State private var showingError = false
    @State private var loggingMealIds: Set<UUID> = []

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var parsedCalories: Int { Int(caloriesText) ?? 0 }
    private var parsedProtein: Int { Int(proteinText) ?? 0 }
    private var parsedCarbs: Int { Int(carbsText) ?? 0 }
    private var parsedFat: Int { Int(fatText) ?? 0 }

    private var mealsById: [UUID: Meal] {
        Dictionary(uniqueKeysWithValues: controller.meals.map { ($0.id, $0) })
    }

    private var groupedMealLogs: [(day: Date, logs: [MealLog])] {
        let grouped = Dictionary(grouping: controller.mealLogs) { Calendar.current.startOfDay(for: $0.consumedAt) }
        return grouped
            .map { ($0.key, $0.value.sorted { $0.consumedAt > $1.consumedAt }) }
            .sorted { $0.day > $1.day }
    }

    private var todayLogs: [MealLog] {
        controller.logsForToday()
    }

    private var todayMacroSummary: MacroSummary {
        controller.macroSummary(for: todayLogs)
    }

    private var todayMealsBreakdown: [(name: String, calories: Int, protein: Int, carbs: Int, fat: Int)] {
        let grouped = Dictionary(grouping: todayLogs, by: { $0.mealId })
        return grouped.compactMap { mealId, logs in
            guard let meal = mealsById[mealId] else { return nil }
            return (
                name: meal.name,
                calories: meal.calories * logs.count,
                protein: meal.protein * logs.count,
                carbs: meal.carbs * logs.count,
                fat: meal.fat * logs.count
            )
        }
        .sorted { $0.calories > $1.calories }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Add Meal") {
                    TextField("Meal name", text: $name)

                    HStack {
                        Text("Calories")
                        Spacer()
                        TextField("0", text: $caloriesText)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                            .frame(width: 100)
                    }

                    HStack {
                        Text("Protein (g)")
                        Spacer()
                        TextField("0", text: $proteinText)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                            .frame(width: 100)
                    }

                    HStack {
                        Text("Carbs (g)")
                        Spacer()
                        TextField("0", text: $carbsText)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                            .frame(width: 100)
                    }

                    HStack {
                        Text("Fat (g)")
                        Spacer()
                        TextField("0", text: $fatText)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                            .frame(width: 100)
                    }

                    Button("Save Meal") {
                        Task {
                            await controller.addMeal(
                                name: name,
                                calories: parsedCalories,
                                protein: parsedProtein,
                                carbs: parsedCarbs,
                                fat: parsedFat
                            )
                            if controller.errorMessage == nil {
                                name = ""
                            }
                        }
                    }
                    .disabled(trimmedName.isEmpty)
                }

                Section("Today's Macro Graph") {
                    macroTotalRow(title: "Calories", value: todayMacroSummary.calories, maxValue: 3000, color: .purple)
                    macroTotalRow(title: "Protein", value: todayMacroSummary.protein, maxValue: 250, suffix: "g", color: .blue)
                    macroTotalRow(title: "Carbs", value: todayMacroSummary.carbs, maxValue: 400, suffix: "g", color: .orange)
                    macroTotalRow(title: "Fat", value: todayMacroSummary.fat, maxValue: 150, suffix: "g", color: .pink)

                    if todayMealsBreakdown.isEmpty {
                        Text("No meals eaten today yet.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(todayMealsBreakdown, id: \.name) { meal in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(meal.name).font(.headline)
                                MacroBar(value: meal.calories, maxValue: max(1, todayMacroSummary.calories), color: .purple)
                                Text("\(meal.calories) kcal · P\(meal.protein) C\(meal.carbs) F\(meal.fat)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
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

    private func macroTotalRow(title: String, value: Int, maxValue: Int, suffix: String = "", color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                Spacer()
                Text("\(value)\(suffix)")
                    .font(.subheadline.bold())
            }
            MacroBar(value: value, maxValue: max(1, maxValue), color: color)
        }
    }
}

private struct MacroBar: View {
    let value: Int
    let maxValue: Int
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            let ratio = maxValue == 0 ? 0 : min(1, CGFloat(value) / CGFloat(maxValue))
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.secondary.opacity(0.15))
                RoundedRectangle(cornerRadius: 6)
                    .fill(color)
                    .frame(width: geometry.size.width * ratio)
            }
        }
        .frame(height: 10)
    }
}
