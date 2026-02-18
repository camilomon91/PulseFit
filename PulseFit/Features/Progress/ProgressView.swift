import SwiftUI
import Charts

struct ProgressDashboardView: View {
    @StateObject var viewModel: ProgressViewModel
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    GroupBox("Weekly Check-ins") {
                        Chart(viewModel.weeklyCheckIns) { point in
                            BarMark(x: .value("Day", point.label), y: .value("Sessions", point.value))
                        }
                        .frame(height: 180)
                    }

                    GroupBox("Protein Adherence (7d)") {
                        Chart(viewModel.weeklyProteinAdherence) { point in
                            LineMark(x: .value("Day", point.label), y: .value("Protein", point.value))
                        }
                        .frame(height: 180)
                    }

                    Text("Correlation Insight")
                        .font(.headline)
                    Text("On days you hit protein, your completed sets tend to be higher. Keep consistency.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("Weekly goal: \(appState.profile.weeklyGymGoal) sessions")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .navigationTitle("Progress")
            .task { await viewModel.load() }
        }
    }
}
