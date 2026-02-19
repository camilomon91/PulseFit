import SwiftUI

struct MainTabView: View {
    @ObservedObject var appController: AppController

    private let tabs: [TabItem] = [
        TabItem(index: 0, title: "Gym", systemImage: "figure.strengthtraining.traditional"),
        TabItem(index: 1, title: "Workouts", systemImage: "dumbbell.fill"),
        TabItem(index: 2, title: "Meals", systemImage: "fork.knife"),
        TabItem(index: 3, title: "Progress", systemImage: "chart.xyaxis.line"),
        TabItem(index: 4, title: "Account", systemImage: "person.crop.circle")
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch appController.selectedTab {
                case 0:
                    CheckInView(
                        workoutController: appController.workoutController,
                        controller: appController.checkInController,
                        mealController: appController.mealController
                    )
                case 1:
                    WorkoutsView(controller: appController.workoutController)
                case 2:
                    MealsView(controller: appController.mealController, checkInController: appController.checkInController)
                case 3:
                    ProgressDashboardView(controller: appController.progressController)
                default:
                    SettingsView(authController: appController.authController)
                }
            }
            .neonScreenBackground()
            .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 84) }

            NeonTabBar(selected: $appController.selectedTab, tabs: tabs) {
                // Center action – feel free to change (e.g., open add-workout sheet)
                appController.selectedTab = 0
            }
        }
        .task { await appController.refreshAll() }
    }
}

private struct NeonTabBar: View {
    @Binding var selected: Int
    let tabs: [TabItem]
    var centerAction: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            tabButton(tabs[0])
            tabButton(tabs[1])

            Spacer(minLength: 0)

            // Center +
            Button(action: centerAction) {
                Image(systemName: "plus")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.black)
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(Neon.neon)
                            .shadow(color: Neon.neon.opacity(0.25), radius: 18, x: 0, y: 10)
                    )
            }
            .offset(y: -18)

            Spacer(minLength: 0)

            tabButton(tabs[2])
            tabButton(tabs[3])
            tabButton(tabs[4])
        }
        .padding(.horizontal, 12)
        .padding(.top, 14)
        .padding(.bottom, 18)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(Neon.stroke, lineWidth: 1)
                )
        )
        .padding(.horizontal, 14)
        .padding(.bottom, 10)
    }

    private func tabButton(_ tab: TabItem) -> some View {
        Button {
            selected = tab.index
        } label: {
            VStack(spacing: 6) {
                Image(systemName: tab.systemImage)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(selected == tab.index ? Neon.neon : Color.white.opacity(0.65))
                Text(tab.title)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(selected == tab.index ? Color.white : Color.white.opacity(0.65))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

private struct TabItem {
    let index: Int
    let title: String
    let systemImage: String
}
