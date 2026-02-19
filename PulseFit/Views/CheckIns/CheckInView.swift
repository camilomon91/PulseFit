import SwiftUI

struct CheckInView: View {
    @ObservedObject var workoutController: WorkoutController
    @ObservedObject var controller: CheckInController

    @State private var selectedWorkoutId: UUID?

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Picker("Workout", selection: $selectedWorkoutId) {
                    Text("Select workout").tag(UUID?.none)
                    ForEach(workoutController.workouts) { workout in
                        Text(workout.name).tag(Optional(workout.id))
                    }
                }
                .pickerStyle(.menu)
                .glassCard()

                if controller.activeCheckIn == nil {
                    Button("Start Check-In") {
                        guard let selectedWorkoutId else { return }
                        Task { await controller.startCheckIn(workoutId: selectedWorkoutId) }
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    ActiveWorkoutView(workoutController: workoutController, controller: controller)
                    Button("Finish Session") { Task { await controller.finishCheckIn() } }
                        .buttonStyle(.borderedProminent)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Gym Check-In")
            .task { await workoutController.loadWorkouts() }
        }
    }
}

private struct ActiveWorkoutView: View {
    @ObservedObject var workoutController: WorkoutController
    @ObservedObject var controller: CheckInController

    @State private var repsByExercise: [UUID: Int] = [:]
    @State private var weightByExercise: [UUID: Double] = [:]

    var body: some View {
        if let workoutId = controller.activeCheckIn?.workoutId,
           let exercises = workoutController.exercisesByWorkout[workoutId] {
            List(exercises) { exercise in
                VStack(alignment: .leading, spacing: 8) {
                    Text(exercise.name).font(.headline)
                    Stepper("Reps: \(repsByExercise[exercise.id, default: exercise.targetReps])", value: Binding(
                        get: { repsByExercise[exercise.id, default: exercise.targetReps] },
                        set: { repsByExercise[exercise.id] = $0 }
                    ), in: 1...40)

                    HStack {
                        Text("Weight (kg)")
                        TextField("0", value: Binding(
                            get: { weightByExercise[exercise.id, default: 20] },
                            set: { weightByExercise[exercise.id] = $0 }
                        ), format: .number)
                        .textFieldStyle(.roundedBorder)
                    }

                    HStack {
                        Button("Start Set") { controller.beginSet(exerciseId: exercise.id) }
                        Button("Complete Set") {
                            let count = controller.setLogs.filter { $0.exerciseId == exercise.id }.count + 1
                            Task {
                                await controller.completeSet(
                                    exerciseId: exercise.id,
                                    setNumber: count,
                                    reps: repsByExercise[exercise.id, default: exercise.targetReps],
                                    weightKg: weightByExercise[exercise.id, default: 20]
                                )
                            }
                        }
                    }
                    .buttonStyle(.bordered)

                    ForEach(controller.setLogs.filter { $0.exerciseId == exercise.id }) { set in
                        Text("Set \(set.setNumber): \(set.reps) reps @ \(set.weightKg, specifier: "%.1f")kg · duration \(set.setDurationSeconds)s · rest \(set.restSeconds)s")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .glassCard()
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
        } else {
            Text("No exercises found for this workout.")
        }
    }
}
