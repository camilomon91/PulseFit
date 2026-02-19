import SwiftUI

struct ProgressDashboardView: View {
    @ObservedObject var controller: ProgressController

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                metricCard(title: "Workouts Completed", value: "\(controller.snapshot.workoutsCompleted)", icon: "checkmark.circle.fill")
                metricCard(title: "Sets Logged", value: "\(controller.snapshot.setsLogged)", icon: "list.number")
                metricCard(title: "Volume", value: "\(controller.snapshot.totalVolumeKg, default: "%.0f") kg", icon: "scalemass")
                metricCard(title: "Meals Tracked", value: "\(controller.snapshot.mealsLogged)", icon: "fork.knife.circle")
                Spacer()
            }
            .padding()
            .navigationTitle("Progress")
        }
    }

    private func metricCard(title: String, value: String, icon: String) -> some View {
        HStack {
            Label(title, systemImage: icon)
            Spacer()
            Text(value).font(.headline)
        }
        .glassCard()
    }
}
