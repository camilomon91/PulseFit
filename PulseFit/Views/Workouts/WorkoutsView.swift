import SwiftUI

struct WorkoutsView: View {
    @ObservedObject var controller: WorkoutController
    @State private var showAddWorkoutSheet = false
    @State private var query = ""

    private var filtered: [Workout] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if q.isEmpty { return controller.workouts }
        return controller.workouts.filter { $0.name.lowercased().contains(q) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    header

                    if controller.workouts.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "dumbbell.fill")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(Neon.neon)
                            Text("No Workouts Yet")
                                .font(.title3.bold())
                            Text("Tap + to create your first workout.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .neonCard()
                        .padding(.top, 8)
                    } else {
                        VStack(spacing: 10) {
                            ForEach(filtered) { workout in
                                NavigationLink {
                                    WorkoutDetailView(workout: workout, controller: controller)
                                } label: {
                                    HStack(spacing: 12) {
                                        Circle()
                                            .fill(Neon.neon.opacity(0.18))
                                            .overlay(
                                                Image(systemName: "figure.strengthtraining.traditional")
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundStyle(Neon.neon)
                                            )
                                            .frame(width: 36, height: 36)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(workout.name)
                                                .font(.headline)
                                                .foregroundStyle(Color.white)
                                            Text("Tap to view exercises")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundStyle(Color.white.opacity(0.45))
                                    }
                                    .contentShape(Rectangle())
                                    .neonCard()
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.top, 2)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 16)
            }
            .neonScreenBackground()
            .navigationTitle("Workouts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddWorkoutSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Neon.neon)
                    }
                }
            }
            .task { await controller.loadWorkouts() }
            .sheet(isPresented: $showAddWorkoutSheet) {
                AddWorkoutSheet(controller: controller)
                    .presentationDetents([.medium])
            }
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Browse")
                    .font(.title2.bold())
                Spacer()
            }

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.white.opacity(0.55))
                TextField("Search workouts", text: $query)
                    .textInputAutocapitalization(.never)
                    .foregroundStyle(Color.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Neon.stroke, lineWidth: 1)
                    )
            )
        }
        .neonCard()
    }
}

private struct AddWorkoutSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var controller: WorkoutController
    @State private var name = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Workout name")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("e.g. Push Day", text: $name)
                        .textFieldStyle(.roundedBorder)
                }

                Button("Save") {
                    Task {
                        await controller.addWorkout(name: name, notes: nil)
                        dismiss()
                    }
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .neonPrimaryButton()

                Button("Cancel") { dismiss() }
                    .neonSecondaryButton()
            }
            .padding()
            .navigationTitle("New Workout")
        }
        .tint(Neon.neon)
    }
}
