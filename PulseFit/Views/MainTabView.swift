import SwiftUI
import Combine

struct MainTabView: View {
    @ObservedObject var appController: AppController

    var body: some View {
        TabView(selection: $appController.selectedTab) {
            WorkoutsView(controller: appController.workoutController)
                .tabItem { Label("Workouts", systemImage: "dumbbell.fill") }
                .tag(0)

            MealsView(controller: appController.mealController, checkInController: appController.checkInController)
                .tabItem { Label("Meals", systemImage: "fork.knife") }
                .tag(1)

            CheckInView(workoutController: appController.workoutController, controller: appController.checkInController)
                .tabItem { Label("Gym", systemImage: "figure.strengthtraining.traditional") }
                .tag(2)

            ProgressDashboardView(controller: appController.progressController)
                .tabItem { Label("Progress", systemImage: "chart.xyaxis.line") }
                .tag(3)

            SettingsView(authController: appController.authController)
                .tabItem { Label("Account", systemImage: "person.crop.circle") }
                .tag(4)
        }
        .task {
            await appController.refreshAll()
        }
    }
}
