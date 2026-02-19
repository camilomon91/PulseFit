import SwiftUI

struct WorkoutDetailView: View {
    let workout: Workout
    @ObservedObject var controller: WorkoutController

    @State private var exerciseName = ""
    @State private var sets = 3
    @State private var reps = 10
    @State private var showingError = false

    private var trimmedExerciseName: String {
        exerciseName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        List {
            Section("Add Exercise") {
                TextField("Exercise", text: $exerciseName)
                Stepper("Sets: \(sets)", value: $sets, in: 1...10)
                Stepper("Reps: \(reps)", value: $reps, in: 1...30)
                Button("Add Exercise") {
                    Task {
                        await controller.addExercise(workoutId: workout.id, name: exerciseName, sets: sets, reps: reps)
                        if controller.errorMessage == nil {
                            exerciseName = ""
                        }
                    }
                }
                .disabled(trimmedExerciseName.isEmpty)
            }

            Section("Exercises") {
                ForEach(controller.exercisesByWorkout[workout.id] ?? [], id: \.id) { exercise in
                    VStack(alignment: .leading) {
                        Text(exercise.name).font(.headline)
                        Text("\(exercise.targetSets)x\(exercise.targetReps)").font(.caption).foregroundStyle(.secondary)
                    }
                }
                .onDelete { indexSet in
                    let exercises = controller.exercisesByWorkout[workout.id] ?? []
                    Task {
                        for index in indexSet {
                            await controller.removeExercise(exercises[index])
                        }
                    }
                }
            }
        }
        .navigationTitle(workout.name)
        .onChange(of: controller.errorMessage) { _, newValue in
            showingError = newValue != nil
        }
        .alert("Couldn't Add Exercise", isPresented: $showingError, presenting: controller.errorMessage) { _ in
            Button("OK") {
                controller.errorMessage = nil
            }
        } message: { message in
            Text(message)
        }
    }
}
