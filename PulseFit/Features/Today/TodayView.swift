import SwiftUI

struct TodayView: View {
    @StateObject var viewModel: TodayViewModel
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(Date.now.formatted(date: .abbreviated, time: .omitted))
                        .font(.title2.bold())
                    Text("Check-in streak: \(viewModel.checkInStreak) days")
                        .foregroundStyle(.secondary)

                    Button {
                        Task { await viewModel.checkInOrEndSession() }
                    } label: {
                        Label(viewModel.activeSession == nil ? "Check In" : "End Session", systemImage: viewModel.activeSession == nil ? "figure.strengthtraining.traditional" : "stop.circle.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.activeSession == nil ? .green : .red, in: RoundedRectangle(cornerRadius: 16))
                            .foregroundStyle(.white)
                    }

                    if let activeSession {
                        NavigationLink {
                            ActiveSessionView(viewModel: SessionViewModel(appState: appState, sessionsRepository: appState.sessionsRepository, exercisesRepository: appState.exercisesRepository, sessionID: activeSession.id))
                        } label: {
                            GoalCard(title: "Active Session", subtitle: "Duration: \(formatDuration(activeSession.duration))", isComplete: false)
                        }
                    }

                    GoalCard(title: "Gym Goal", subtitle: "\(viewModel.activeSession == nil ? "Not checked in yet" : "Training in progress")", isComplete: viewModel.activeSession != nil)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Macros Today").font(.headline)
                        MacroProgressRow(name: "Protein", consumed: viewModel.todayMacros.protein, goal: appState.profile.proteinGoal, emphasize: true)
                        MacroProgressRow(name: "Carbs", consumed: viewModel.todayMacros.carbs, goal: appState.profile.carbGoal)
                        MacroProgressRow(name: "Fat", consumed: viewModel.todayMacros.fat, goal: appState.profile.fatGoal)
                    }
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))

                    Text("Motivation: You're 2 sessions away from your weekly goal.")
                        .font(.subheadline)
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                }
                .padding()
            }
            .navigationTitle("Today")
            .task { await viewModel.refresh() }
        }
    }

    private func formatDuration(_ interval: TimeInterval) -> String {
        let minutes = Int(interval / 60)
        return "\(minutes)m"
    }
}
