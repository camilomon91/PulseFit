import SwiftUI

/// A safe detail sheet that works with unknown CheckIn/Workout shapes.
/// - Assumes only:
///   - CheckIn is Identifiable
///   - workoutsById is keyed by UUID
struct DayDetailSheet<CheckInType: Identifiable, WorkoutType>: View {
    let day: Date
    let checkIns: [CheckInType]
    let workoutsById: [UUID: WorkoutType]

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    headerCard

                    if checkIns.isEmpty {
                        emptyCard
                    } else {
                        ForEach(checkIns) { checkIn in
                            checkInCard(checkIn)
                        }
                    }
                }
                .padding(16)
                .padding(.top, 8)
            }
            .neonScreenBackground()
            .navigationTitle(titleForDay(day))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Neon.neon)
                }
            }
        }
    }

    // MARK: - Cards

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Daily Activity")
                .font(.headline)
                .foregroundStyle(Color.white)

            Text("Check-ins: \(checkIns.count)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Quick "summary" chips, only if those properties exist
            let summary = summarize(checkIns: checkIns, workoutsById: workoutsById)
            if !summary.isEmpty {
                WrapHStack(spacing: 8, lineSpacing: 8) {
                    ForEach(summary, id: \.self) { chip in
                        Text(chip)
                            .font(.caption.weight(.semibold))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 10)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(Color.white.opacity(0.06))
                                    .overlay(
                                        Capsule(style: .continuous)
                                            .stroke(Neon.stroke, lineWidth: 1)
                                    )
                            )
                            .foregroundStyle(Color.white.opacity(0.9))
                    }
                }
            }
        }
        .neonCard()
    }

    private var emptyCard: some View {
        VStack(spacing: 10) {
            Image(systemName: "calendar")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(Neon.neon)

            Text("No check-ins for this day")
                .font(.headline)
                .foregroundStyle(Color.white)

            Text("Try logging a workout or a check-in to see details here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .neonCard()
    }

    private func checkInCard(_ checkIn: CheckInType) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Circle()
                    .fill(Neon.neon.opacity(0.18))
                    .overlay(
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Neon.neon)
                    )
                    .frame(width: 34, height: 34)

                VStack(alignment: .leading, spacing: 2) {
                    Text(primaryTitle(for: checkIn))
                        .font(.headline)
                        .foregroundStyle(Color.white)

                    if let timeString = timeStringIfPresent(in: checkIn) {
                        Text(timeString)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()
            }

            let rows = detailRows(for: checkIn)
            if !rows.isEmpty {
                VStack(spacing: 8) {
                    ForEach(rows.indices, id: \.self) { i in
                        HStack {
                            Text(rows[i].0)
                                .foregroundStyle(Color.white.opacity(0.75))
                            Spacer()
                            Text(rows[i].1)
                                .foregroundStyle(Color.white)
                        }
                        .font(.subheadline)
                    }
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
            } else {
                // fallback: still show something meaningful
                Text(String(describing: checkIn))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .neonCard()
    }

    // MARK: - Formatting + Introspection

    private func titleForDay(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: date)
    }

    private func primaryTitle(for checkIn: CheckInType) -> String {
        // If check-in has workoutId and the workout has a "name", show it.
        if let workoutId: UUID = mirrorValue(checkIn, keys: ["workoutId", "workoutID", "workout_id"]),
           let workout = workoutsById[workoutId] {
            if let name: String = mirrorValue(workout, keys: ["name", "title"]) {
                return name
            }
            return "Workout"
        }
        // If check-in has a "title" or "name", use it
        if let t: String = mirrorValue(checkIn, keys: ["title", "name"]) {
            return t
        }
        return "Check-in"
    }

    private func timeStringIfPresent(in checkIn: CheckInType) -> String? {
        // common keys: createdAt, date, timestamp
        if let d: Date = mirrorValue(checkIn, keys: ["createdAt", "date", "timestamp"]) {
            let f = DateFormatter()
            f.dateFormat = "h:mm a"
            return f.string(from: d)
        }
        return nil
    }

    private func detailRows(for checkIn: CheckInType) -> [(String, String)] {
        var rows: [(String, String)] = []

        // Add whatever exists — no assumptions required.
        if let mood: String = mirrorValue(checkIn, keys: ["mood"]) {
            rows.append(("Mood", mood))
        }
        if let weight: Double = mirrorValue(checkIn, keys: ["weight", "weightKg", "weight_kg"]) {
            rows.append(("Weight", String(format: "%.1f", weight)))
        } else if let weightInt: Int = mirrorValue(checkIn, keys: ["weight"]) {
            rows.append(("Weight", "\(weightInt)"))
        }

        if let calories: Int = mirrorValue(checkIn, keys: ["calories", "caloriesBurned"]) {
            rows.append(("Calories", "\(calories)"))
        }

        if let water: Double = mirrorValue(checkIn, keys: ["water", "waterLiters", "water_liters"]) {
            rows.append(("Water", String(format: "%.1f L", water)))
        }

        if let notes: String = mirrorValue(checkIn, keys: ["notes", "comment", "text"]) {
            if !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                rows.append(("Notes", notes))
            }
        }

        // If it references a workout, show its name too.
        if let workoutId: UUID = mirrorValue(checkIn, keys: ["workoutId", "workoutID", "workout_id"]),
           let workout = workoutsById[workoutId],
           let name: String = mirrorValue(workout, keys: ["name", "title"]) {
            rows.insert(("Workout", name), at: 0)
        }

        return rows
    }

    private func summarize(checkIns: [CheckInType], workoutsById: [UUID: WorkoutType]) -> [String] {
        var chips: [String] = []

        // Example: count distinct workout IDs if present.
        var workoutIds = Set<UUID>()
        for c in checkIns {
            if let id: UUID = mirrorValue(c, keys: ["workoutId", "workoutID", "workout_id"]) {
                workoutIds.insert(id)
            }
        }
        if !workoutIds.isEmpty {
            chips.append("\(workoutIds.count) workout(s)")
        }

        // Example: sum calories if present.
        let totalCalories = checkIns.compactMap { (c: CheckInType) -> Int? in
            mirrorValue(c, keys: ["calories", "caloriesBurned"])
        }.reduce(0, +)

        if totalCalories > 0 {
            chips.append("\(totalCalories) cal")
        }

        return chips
    }

    /// Reads a value from an arbitrary object/struct using Mirror keys.
    private func mirrorValue<T>(_ obj: Any, keys: [String]) -> T? {
        let m = Mirror(reflecting: obj)
        for child in m.children {
            guard let label = child.label else { continue }
            if keys.contains(label) {
                return child.value as? T
            }
        }
        // Search superclass chain if needed
        if let sup = m.superclassMirror {
            for child in sup.children {
                guard let label = child.label else { continue }
                if keys.contains(label) {
                    return child.value as? T
                }
            }
        }
        return nil
    }
}

/// Small helper layout (keeps chips wrapping nicely)
private struct WrapHStack<Content: View>: View {
    let spacing: CGFloat
    let lineSpacing: CGFloat
    @ViewBuilder let content: Content

    init(spacing: CGFloat, lineSpacing: CGFloat, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.lineSpacing = lineSpacing
        self.content = content()
    }

    var body: some View {
        // Simple wrap using adaptive grid (no extra types/models needed)
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: spacing)], spacing: lineSpacing) {
            content
        }
    }
}
