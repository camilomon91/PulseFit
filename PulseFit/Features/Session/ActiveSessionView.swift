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
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Set \(set.setIndex)")
                                    Spacer()
                                    Button(set.isCompleted ? "Done" : "Mark Done") {
                                        Task { await viewModel.toggleSetCompleted(set) }
                                    }
                                    .buttonStyle(.bordered)
                                }

                                HStack {
                                    Button("-5 lb") {
                                        let newWeight = max(0, (set.weight ?? 45) - 5)
                                        Task { await viewModel.updateSet(set, weight: newWeight, reps: set.reps) }
                                    }
                                    .buttonStyle(.bordered)

                                    Text("\(Int(set.weight ?? 0)) lb")
                                        .frame(maxWidth: .infinity)

                                    Button("+5 lb") {
                                        let newWeight = (set.weight ?? 45) + 5
                                        Task { await viewModel.updateSet(set, weight: newWeight, reps: set.reps) }
                                    }
                                    .buttonStyle(.bordered)
                                }

                                HStack {
                                    Button("-1 rep") {
                                        let newReps = max(0, (set.reps ?? 8) - 1)
                                        Task { await viewModel.updateSet(set, weight: set.weight, reps: newReps) }
                                    }
                                    .buttonStyle(.bordered)

                                    Text("\(set.reps ?? 0) reps")
                                        .frame(maxWidth: .infinity)

                                    Button("+1 rep") {
                                        let newReps = (set.reps ?? 8) + 1
                                        Task { await viewModel.updateSet(set, weight: set.weight, reps: newReps) }
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    Task { await viewModel.deleteSet(set.id) }
                                } label: {
                                    Label("Delete Set", systemImage: "trash")
                                }
                            }
                        }

                        Button {
                            Task { await viewModel.addSet(sessionExerciseID: sessionExercise.id) }
                        } label: {
                            Label("Add Set", systemImage: "plus")
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            Task { await viewModel.deleteExercise(sessionExercise.id) }
                        } label: {
                            Label("Delete Exercise", systemImage: "trash")
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
