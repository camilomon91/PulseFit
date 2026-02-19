import SwiftUI

struct WorkoutDetailView: View {
    let workout: Workout
    @ObservedObject var controller: WorkoutController

    @State private var exerciseName = ""
    @State private var sets = 3
    @State private var reps = 10

    var body: some View {
        List {
            Section("Add Exercise") {
                TextField("Exercise", text: $exerciseName)
                Stepper("Sets: \(sets)", value: $sets, in: 1...10)
                Stepper("Reps: \(reps)", value: $reps, in: 1...30)
                Button("Add Exercise") {
                    Task {
                        await controller.addExercise(workoutId: workout.id, name: exerciseName, sets: sets, reps: reps)
                        exerciseName = ""
                    }
                }
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
    }
}
