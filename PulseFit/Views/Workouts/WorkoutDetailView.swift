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

    private var exercises: [Exercise] {
        controller.exercisesByWorkout[workout.id] ?? []
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                addExerciseCard
                exercisesCard
            }
            .padding(16)
            .padding(.top, 6)
        }
        .neonScreenBackground()
        .navigationTitle(workout.name)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: controller.errorMessage) { _, newValue in
            showingError = (newValue != nil)
        }
        .alert("Couldn't complete action", isPresented: $showingError) {
            Button("OK") { controller.errorMessage = nil }
        } message: {
            Text(controller.errorMessage ?? "Unknown error.")
        }
        .task {
            // Your controller preloads exercises inside loadWorkouts().
            // If we landed here via a deep link / direct nav and exercises aren't in-memory yet,
            // reload once.
            if controller.exercisesByWorkout[workout.id] == nil {
                await controller.loadWorkouts()
            }
        }
    }

    private var addExerciseCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Add Exercise")
                .font(.headline)
                .foregroundStyle(Color.white)

            VStack(alignment: .leading, spacing: 8) {
                Text("Name")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                TextField("e.g. Push Ups", text: $exerciseName)
                    .textInputAutocapitalization(.words)
                    .textFieldStyle(.roundedBorder)
            }

            HStack(spacing: 12) {
                stepperPill(title: "Sets", value: sets, range: 1...10) { sets = $0 }
                stepperPill(title: "Reps", value: reps, range: 1...30) { reps = $0 }
            }

            Button {
                Task {
                    await controller.addExercise(
                        workoutId: workout.id,
                        name: exerciseName,
                        sets: sets,
                        reps: reps
                    )
                    // If add worked, controller sets errorMessage = nil
                    if controller.errorMessage == nil {
                        exerciseName = ""
                    }
                }
            } label: {
                Text("Add Exercise")
            }
            .disabled(trimmedExerciseName.isEmpty)
            .neonPrimaryButton()
        }
        .neonCard()
    }

    private var exercisesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Exercises")
                    .font(.headline)
                    .foregroundStyle(Color.white)

                Spacer()

                Text("\(exercises.count)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            if exercises.isEmpty {
                Text("No exercises yet. Add one above.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 10) {
                    ForEach(exercises, id: \.id) { exercise in
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(exercise.name)
                                    .font(.headline)
                                    .foregroundStyle(Color.white)

                                Text("\(exercise.targetSets)x\(exercise.targetReps)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Button {
                                Task { await controller.removeExercise(exercise) }
                            } label: {
                                Image(systemName: "trash")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color.white.opacity(0.70))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.white.opacity(0.06))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(Neon.stroke, lineWidth: 1)
                                )
                        )
                    }
                }
            }
        }
        .neonCard()
    }

    private func stepperPill(
        title: String,
        value: Int,
        range: ClosedRange<Int>,
        onChange: @escaping (Int) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                Button {
                    onChange(max(range.lowerBound, value - 1))
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.black)
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(Neon.neon))
                }
                .buttonStyle(.plain)

                Text("\(value)")
                    .font(.headline)
                    .foregroundStyle(Color.white)
                    .frame(minWidth: 28)

                Button {
                    onChange(min(range.upperBound, value + 1))
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.black)
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(Neon.neon))
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Neon.stroke, lineWidth: 1)
                )
        )
    }
}
