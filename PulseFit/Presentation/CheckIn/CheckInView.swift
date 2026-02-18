import SwiftUI

struct CheckInView: View {
    let userID: UUID
    let workouts: [Workout]
    @StateObject var viewModel: CheckInViewModel
    @State private var reps = "10"
    @State private var weight = "20"
    @State private var selectedExerciseID: UUID?
    @State private var setStart = Date()

    var body: some View {
        VStack(spacing: 16) {
            if viewModel.activeCheckIn == nil {
                GlassCard {
                    Text("Start Gym Check-In").font(.headline)
                    ForEach(workouts) { workout in
                        Button(workout.name) {
                            Task { await viewModel.start(userID: userID, workoutID: workout.id) }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            } else {
                GlassCard {
                    Text("Workout in progress").font(.headline)
                    if let workout = workouts.first(where: { $0.id == viewModel.selectedWorkoutID }) {
                        Picker("Exercise", selection: $selectedExerciseID) {
                            Text("Select").tag(UUID?.none)
                            ForEach(workout.exercises) { exercise in
                                Text(exercise.name).tag(UUID?.some(exercise.id))
                            }
                        }

                        TextField("Reps", text: $reps).keyboardType(.numberPad)
                        TextField("Weight", text: $weight).keyboardType(.decimalPad)

                        Button("Mark Set Done") {
                            guard let exerciseID = selectedExerciseID,
                                  let repsInt = Int(reps),
                                  let weightDouble = Double(weight) else { return }
                            let end = Date()
                            Task {
                                await viewModel.completeSet(
                                    exerciseID: exerciseID,
                                    reps: repsInt,
                                    weight: weightDouble,
                                    start: setStart,
                                    end: end
                                )
                                setStart = Date()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }

                    Button("Finish Session") {
                        Task { await viewModel.finish() }
                    }
                    .buttonStyle(.bordered)
                }
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Check-In")
    }
}
