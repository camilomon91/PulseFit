import SwiftUI
import Combine

struct WorkoutsView: View {
    @ObservedObject var controller: WorkoutController
    @State private var newWorkoutName = ""

    var body: some View {
        NavigationStack {
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
            .navigationTitle("Workouts")
            .task { await controller.loadWorkouts() }
        }
    }
}
