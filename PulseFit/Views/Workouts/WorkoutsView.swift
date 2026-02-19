import SwiftUI
import Combine

struct WorkoutsView: View {
    @ObservedObject var controller: WorkoutController
    @State private var newWorkoutName = ""
    @State private var showAddWorkoutSheet = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                List {
                    Section("Create Workout") {
                        TextField("Workout name", text: $newWorkoutName)
                        Button("Add") {
                            Task {
                                await controller.addWorkout(name: newWorkoutName, notes: nil)
                                newWorkoutName = ""
                            }
                        }
                    }

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
                .scrollContentBackground(.hidden)
                .background(LinearGradient(colors: [.cyan.opacity(0.2), .indigo.opacity(0.25)], startPoint: .top, endPoint: .bottom))

                Button {
                    showAddWorkoutSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.accentColor)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
                .accessibilityLabel("Add Workout")
            }
            .navigationTitle("Workouts")
            .task { await controller.loadWorkouts() }
            .sheet(isPresented: $showAddWorkoutSheet) {
                AddWorkoutSheet(controller: controller)
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
