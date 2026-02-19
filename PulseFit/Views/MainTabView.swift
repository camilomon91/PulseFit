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

    private let tabBarReservedHeight: CGFloat = 100

    var body: some View {
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
        .safeAreaPadding(.bottom, tabBarReservedHeight)
        .overlay(alignment: .bottom) {
            NeonTabBar(selected: $appController.selectedTab, tabs: tabs)
        }
        .task { await appController.refreshAll() }
    }
}

private struct NeonTabBar: View {
    @Binding var selected: Int
    let tabs: [TabItem]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.index) { tab in
                tabButton(tab)
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 12)
        .padding(.bottom, 14)
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
