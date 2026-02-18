import SwiftUI
import Combine

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Goals") {
                    Stepper("Weekly gym target: \(viewModel.profile.weeklyGymGoal)", value: $viewModel.profile.weeklyGymGoal, in: 1...7)
                    Stepper("Calories: \(viewModel.profile.calorieGoal)", value: $viewModel.profile.calorieGoal, in: 1200...5000, step: 50)
                    Stepper("Protein: \(viewModel.profile.proteinGoal)", value: $viewModel.profile.proteinGoal, in: 50...320, step: 5)
                    Stepper("Carbs: \(viewModel.profile.carbGoal)", value: $viewModel.profile.carbGoal, in: 50...500, step: 5)
                    Stepper("Fat: \(viewModel.profile.fatGoal)", value: $viewModel.profile.fatGoal, in: 20...180, step: 5)
                }

                Section("Preferences") {
                    Picker("Units", selection: $viewModel.profile.units) {
                        ForEach(Units.allCases, id: \.self) { unit in
                            Text(unit.rawValue.capitalized).tag(unit)
                        }
                    }

                    Picker("Progression", selection: $viewModel.profile.progressionMethod) {
                        ForEach(ProgressionMethod.allCases, id: \.self) { method in
                            Text(method.rawValue).tag(method)
                        }
                    }
                }

                Button("Save") {
                    viewModel.save()
                }
            }
            .navigationTitle("Profile")
        }
    }
}
