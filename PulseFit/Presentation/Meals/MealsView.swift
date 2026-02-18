import SwiftUI

struct MealsView: View {
    @Binding var meals: [Meal]

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(meals) { meal in
                    GlassCard {
                        Text(meal.name)
                            .font(.headline)
                        HStack {
                            Label("\(meal.calories) kcal", systemImage: "flame")
                            Spacer()
                            Text("P \(meal.protein)g")
                            Text("C \(meal.carbs)g")
                            Text("F \(meal.fats)g")
                        }
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    }
                }
                if meals.isEmpty {
                    Text("No meals yet. Add your regular meals.")
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle("Meals")
    }
}
