import SwiftUI

struct ActiveSessionView: View {
    @StateObject var viewModel: SessionViewModel

    var body: some View {
        List {
            if let session = viewModel.session {
                Section("Session") {
                    Text("Elapsed: \(Int(session.duration / 60)) minutes")
                    Text("Exercises: \(session.exercises.count)")
                }

                Section("Add Exercise") {
                    ForEach(viewModel.availableExercises, id: \.id) { exercise in
                        Button(exercise.name) {
                            Task { await viewModel.addExercise(exercise) }
                        }
                    }
                }

                ForEach(session.exercises, id: \.id) { sessionExercise in
                    Section(sessionExercise.exercise.name) {
                        Text(sessionExercise.notes ?? "Suggested next set shown after history builds")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        ForEach(sessionExercise.sets, id: \.id) { set in
                            HStack {
                                Text("Set \(set.setIndex)")
                                Spacer()
                                Text(set.isCompleted ? "Done" : "Pending")
                                    .foregroundStyle(set.isCompleted ? .green : .secondary)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                Task { await viewModel.toggleSetCompleted(set) }
                            }
                        }

                        Button {
                            Task { await viewModel.addSet(sessionExerciseID: sessionExercise.id) }
                        } label: {
                            Label("Add Set", systemImage: "plus")
                        }
                    }
                }
            } else {
                ContentUnavailableView("No Active Session", systemImage: "figure.run")
            }
        }
        .navigationTitle("Today Session")
        .task { await viewModel.refresh() }
    }
}
