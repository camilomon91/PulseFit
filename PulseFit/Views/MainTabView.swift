import SwiftUI
import Combine

struct MainTabView: View {
    @ObservedObject var appController: AppController

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

            NeonTabBar(selected: $appController.selectedTab) {
                // Center action – feel free to change (e.g., open add-workout sheet)
                appController.selectedTab = 0
            }
        }
        .task { await appController.refreshAll() }
    }
}

private struct NeonTabBar: View {
    @Binding var selected: Int
    var centerAction: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            tabButton(index: 0, title: "Gym", system: "figure.strengthtraining.traditional")
            tabButton(index: 1, title: "Workouts", system: "dumbbell.fill")

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

            tabButton(index: 2, title: "Meals", system: "fork.knife")
            tabButton(index: 3, title: "Progress", system: "chart.xyaxis.line")
            tabButton(index: 4, title: "Account", system: "person.crop.circle")
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

    private func tabButton(index: Int, title: String, system: String) -> some View {
        Button {
            selected = index
        } label: {
            VStack(spacing: 6) {
                Image(systemName: system)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(selected == index ? Neon.neon : Color.white.opacity(0.65))
                Text(title)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(selected == index ? Color.white : Color.white.opacity(0.65))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
