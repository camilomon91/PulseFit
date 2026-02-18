import SwiftUI

struct WorkoutsView: View {
    @Binding var workouts: [Workout]

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(workouts) { workout in
                    GlassCard {
                        Text(workout.name)
                            .font(.headline)
                        if let notes = workout.notes, !notes.isEmpty {
                            Text(notes).font(.footnote).foregroundStyle(.secondary)
                        }
                        Text("Exercises: \(workout.exercises.count)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                if workouts.isEmpty {
                    Text("No workouts yet. Add one to begin.")
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle("Workouts")
    }
}
