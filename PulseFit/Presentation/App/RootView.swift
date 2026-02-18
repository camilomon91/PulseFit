import SwiftUI

struct RootView: View {
    @EnvironmentObject var container: AppContainer
    @StateObject private var appVM: AppViewModel
    @StateObject private var dashboardVM: DashboardViewModel
    @StateObject private var checkInVM: CheckInViewModel

    init(container: AppContainer) {
        _appVM = StateObject(wrappedValue: AppViewModel(container: container))
        _dashboardVM = StateObject(wrappedValue: DashboardViewModel(container: container))
        _checkInVM = StateObject(wrappedValue: CheckInViewModel(container: container))
    }

    var body: some View {
        Group {
            if let session = appVM.session {
                TabView {
                    NavigationStack {
                        WorkoutsView(workouts: $dashboardVM.workouts)
                    }
                    .tabItem { Label("Workouts", systemImage: "figure.strengthtraining.traditional") }

                    NavigationStack {
                        MealsView(meals: $dashboardVM.meals)
                    }
                    .tabItem { Label("Meals", systemImage: "fork.knife") }

                    NavigationStack {
                        CheckInView(userID: session.userID, workouts: dashboardVM.workouts, viewModel: checkInVM)
                    }
                    .tabItem { Label("Check-In", systemImage: "dumbbell") }

                    NavigationStack {
                        ProgressViewScreen(snapshots: dashboardVM.progress)
                    }
                    .tabItem { Label("Progress", systemImage: "chart.xyaxis.line") }
                }
                .task {
                    await dashboardVM.refresh(userID: session.userID)
                }
            } else {
                AuthView(viewModel: AuthViewModel(container: container)) { authenticated in
                    appVM.session = authenticated
                }
            }
        }
        .task {
            if appVM.session == nil {
                await appVM.bootstrap()
            }
        }
    }
}
