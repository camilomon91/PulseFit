import SwiftUI
import Combine

struct WorkoutsView: View {
    @ObservedObject var controller: WorkoutController
    @State private var showAddWorkoutSheet = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                List {
                    if controller.workouts.isEmpty {
                        ContentUnavailableView(
                            "No Workouts Yet",
                            systemImage: "dumbbell",
                            description: Text("Tap + to create your first workout.")
                        )
                        .listRowBackground(Color.clear)
                    } else {
                        Section {
                            ForEach(controller.workouts) { workout in
                                NavigationLink(workout.name) {
                                    WorkoutDetailView(workout: workout, controller: controller)
                                }
                            }
                            .onDelete { indexSet in
                                Task {
                                    for index in indexSet {
                                        await controller.removeWorkout(id: controller.workouts[index].id)
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(Color(uiColor: .systemGroupedBackground))

                Button {
                    showAddWorkoutSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.accentColor.gradient)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.18), radius: 10, y: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
                .accessibilityLabel("Add Workout")
            }
            .navigationTitle("Workouts")
            .task { await controller.loadWorkouts() }
            .sheet(isPresented: $showAddWorkoutSheet) {
                AddWorkoutSheet(controller: controller)
                    .presentationDetents([.medium])
            }
        }
    }
}

private struct AddWorkoutSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var controller: WorkoutController
    @State private var name = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Workout name", text: $name)
            }
            .navigationTitle("New Workout")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        Task {
                            await controller.addWorkout(name: name, notes: nil)
                            dismiss()
                        }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
