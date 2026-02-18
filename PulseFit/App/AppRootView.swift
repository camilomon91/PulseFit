import SwiftUI

struct AppRootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        TabView {
            TodayView(viewModel: TodayViewModel(appState: appState, sessionsRepository: appState.sessionsRepository, nutritionRepository: appState.nutritionRepository))
                .tabItem { Label("Today", systemImage: "sun.max.fill") }

            WorkoutsView(viewModel: WorkoutsViewModel(exercisesRepository: appState.exercisesRepository))
                .tabItem { Label("Workouts", systemImage: "dumbbell.fill") }

            NutritionView(viewModel: NutritionViewModel(appState: appState, nutritionRepository: appState.nutritionRepository))
                .tabItem { Label("Nutrition", systemImage: "fork.knife") }

            ProgressDashboardView(viewModel: ProgressViewModel(appState: appState, sessionsRepository: appState.sessionsRepository, nutritionRepository: appState.nutritionRepository))
                .tabItem { Label("Progress", systemImage: "chart.xyaxis.line") }

            ProfileView(viewModel: ProfileViewModel(appState: appState))
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
    }
}
