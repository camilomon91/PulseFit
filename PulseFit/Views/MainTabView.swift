import SwiftUI

struct MainTabView: View {
    @ObservedObject var appController: AppController

    var body: some View {
        TabView(selection: $appController.selectedTab) {
            CheckInView(
                workoutController: appController.workoutController,
                controller: appController.checkInController,
                mealController: appController.mealController
            )
            .tabItem {
                Label("Gym", systemImage: "figure.strengthtraining.traditional")
            }
            .tag(0)

            WorkoutsView(controller: appController.workoutController)
                .tabItem {
                    Label("Workouts", systemImage: "dumbbell.fill")
                }
                .tag(1)

            MealsView(controller: appController.mealController, checkInController: appController.checkInController)
                .tabItem {
                    Label("Meals", systemImage: "fork.knife")
                }
                .tag(2)

            ProgressDashboardView(controller: appController.progressController)
                .tabItem {
                    Label("Progress", systemImage: "chart.xyaxis.line")
                }
                .tag(3)

            SettingsView(authController: appController.authController)
                .tabItem {
                    Label("Account", systemImage: "person.crop.circle")
                }
                .tag(4)
        }
        .tint(Neon.neon)
        .task { await appController.refreshAll() }
    }
}
