import SwiftUI

struct CheckInView: View {
    @ObservedObject var workoutController: WorkoutController
    @ObservedObject var controller: CheckInController
    @ObservedObject var mealController: MealController

    @State private var selectedWorkoutId: UUID?

    private var isWorkoutActive: Bool {
        controller.activeCheckIn != nil
    }

    private var todayMacros: MacroSummary {
        mealController.macroSummary(for: mealController.logsForToday())
    }

    private var todaysWorkoutDuration: Int {
        let calendar = Calendar.current
        let sessionsToday = controller.checkInHistory.filter { calendar.isDateInToday($0.startedAt) }

        let completed = sessionsToday.reduce(0) { total, checkIn in
            guard let completedAt = checkIn.completedAt else { return total }
            return total + max(0, Int(completedAt.timeIntervalSince(checkIn.startedAt)))
        }

        let active = controller.activeCheckIn.map { max(0, Int(Date().timeIntervalSince($0.startedAt))) } ?? 0
        return completed + active
    }

    var body: some View {
        NavigationStack {
            Group {
                if isWorkoutActive {
                    ActiveWorkoutView(workoutController: workoutController, controller: controller)
                } else {
                    VStack(spacing: 16) {
                        summaryCards
                        workoutPicker

                        Button("Start Check-In") {
                            guard let selectedWorkoutId else { return }
                            Task { await controller.startCheckIn(workoutId: selectedWorkoutId) }
                        }
                        .disabled(selectedWorkoutId == nil)
                        .neonPrimaryButton()

                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("Gym")
            .neonScreenBackground()
            .safeAreaInset(edge: .bottom) {
                if isWorkoutActive {
                    Button("Finish Session") {
                        Task { await controller.finishCheckIn() }
                    }
                    .neonPrimaryButton()
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                    .background(.clear)
                }
            }
            .task {
                await workoutController.loadWorkouts()
                await controller.loadHistory()
                await mealController.loadMeals()
            }
        }
    }

    private var workoutPicker: some View {
        Picker("Workout", selection: $selectedWorkoutId) {
            Text("Select workout").tag(UUID?.none)
            ForEach(workoutController.workouts) { workout in
                Text(workout.name).tag(Optional(workout.id))
            }
        }
        .pickerStyle(.menu)
        .neonCard()
    }

    private var summaryCards: some View {
        VStack(spacing: 10) {
            HStack {
                Label("Today's Macros", systemImage: "fork.knife.circle")
                Spacer()
                Text("\(todayMacros.calories) kcal")
                    .font(.headline)
            }

            HStack(spacing: 12) {
                macroPill(label: "P", value: todayMacros.protein, color: .blue)
                macroPill(label: "C", value: todayMacros.carbs, color: .orange)
                macroPill(label: "F", value: todayMacros.fat, color: .pink)
            }

            Divider()

            HStack {
                Label("Workout Duration Today", systemImage: "timer")
                Spacer()
                Text(formatDuration(todaysWorkoutDuration))
                    .font(.headline)
            }
        }
        .padding(12)
        .neonCard()
    }

    private func macroPill(label: String, value: Int, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(value)g")
                .font(.subheadline.bold())
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(color.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }

        return "\(minutes)m"
    }
}

private struct ActiveWorkoutView: View {
    @ObservedObject var workoutController: WorkoutController
    @ObservedObject var controller: CheckInController

    @State private var repsInputByExercise: [UUID: String] = [:]
    @State private var weightInputByExercise: [UUID: String] = [:]

    var body: some View {
        if let workoutId = controller.activeCheckIn?.workoutId,
           let exercises = workoutController.exercisesByWorkout[workoutId] {
            VStack(spacing: 12) {
                TimelineView(.periodic(from: .now, by: 1)) { timeline in
                    let elapsed = max(0, Int(timeline.date.timeIntervalSince(controller.activeCheckIn?.startedAt ?? timeline.date)))

                    HStack {
                        Label("Workout Elapsed", systemImage: "timer")
                            .foregroundStyle(Color.white.opacity(0.85))
                        Spacer()
                        Text(formattedClock(elapsed))
                            .font(.headline)
                            .foregroundStyle(Color.white)
                    }
                    .padding(12)
                    .neonCard()
                    .padding(.horizontal, 16)
                }

                List(exercises) { exercise in
                VStack(alignment: .leading, spacing: 10) {
                    Text(exercise.name).font(.headline)

                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Reps").font(.caption).foregroundStyle(.secondary)
                            TextField(
                                "\(exercise.targetReps)",
                                text: Binding(
                                    get: { repsInputByExercise[exercise.id] ?? "\(exercise.targetReps)" },
                                    set: { repsInputByExercise[exercise.id] = $0 }
                                )
                            )
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Weight (kg)").font(.caption).foregroundStyle(.secondary)
                            TextField(
                                "20",
                                text: Binding(
                                    get: { weightInputByExercise[exercise.id] ?? "20" },
                                    set: { weightInputByExercise[exercise.id] = $0 }
                                )
                            )
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                        }
                    }

                    HStack {
                        Button("-1 Rep") {
                            let current = parseInt(repsInputByExercise[exercise.id], fallback: exercise.targetReps)
                            repsInputByExercise[exercise.id] = "\(max(1, current - 1))"
                        }

                        Button("+1 Rep") {
                            let current = parseInt(repsInputByExercise[exercise.id], fallback: exercise.targetReps)
                            repsInputByExercise[exercise.id] = "\(current + 1)"
                        }

                        Button("+2.5kg") {
                            let current = parseDouble(weightInputByExercise[exercise.id], fallback: 20)
                            weightInputByExercise[exercise.id] = String(format: "%.1f", current + 2.5)
                        }
                    }
                    .buttonStyle(.bordered)

                    HStack {
                        Button("Start Set") { controller.beginSet(exerciseId: exercise.id) }
                        Button("Complete Set") {
                            let count = controller.setLogs.filter { $0.exerciseId == exercise.id }.count + 1
                            Task {
                                await controller.completeSet(
                                    exerciseId: exercise.id,
                                    setNumber: count,
                                    reps: max(1, parseInt(repsInputByExercise[exercise.id], fallback: exercise.targetReps)),
                                    weightKg: max(0, parseDouble(weightInputByExercise[exercise.id], fallback: 20))
                                )
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)

                    TimelineView(.periodic(from: .now, by: 1)) { timeline in
                        let now = timeline.date
                        let setElapsed = elapsedSince(controller.setStartTimes[exercise.id], now: now)
                        let restElapsed = elapsedSince(controller.lastSetCompletionByExercise[exercise.id], now: now)

                        VStack(alignment: .leading, spacing: 4) {
                            if let setElapsed {
                                Label("Set elapsed: \(formattedClock(setElapsed))", systemImage: "stopwatch")
                                    .font(.caption)
                                    .foregroundStyle(.blue)
                            }

                            if let restElapsed {
                                HStack {
                                    Label("Rest elapsed: \(formattedClock(restElapsed))", systemImage: "timer")
                                        .font(.caption)
                                        .foregroundStyle(.orange)
                                    Spacer()
                                    Button("End Rest") {
                                        controller.endRest(exerciseId: exercise.id)
                                    }
                                    .font(.caption)
                                    .buttonStyle(.bordered)
                                }
                            }
                        }
                    }

                    ForEach(controller.setLogs.filter { $0.exerciseId == exercise.id }) { set in
                        Text("Set \(set.setNumber): \(set.reps) reps @ \(set.weightKg, specifier: "%.1f")kg · duration \(set.setDurationSeconds)s · rest \(set.restSeconds)s")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(12)
                .neonCard()
                .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
            }
        } else {
            Text("No exercises found for this workout.")
        }
    }

    private func elapsedSince(_ date: Date?, now: Date) -> Int? {
        guard let date else { return nil }
        return max(0, Int(now.timeIntervalSince(date)))
    }

    private func formattedClock(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remaining = seconds % 60
        return String(format: "%02d:%02d", minutes, remaining)
    }

    private func parseInt(_ value: String?, fallback: Int) -> Int {
        guard let value, let parsed = Int(value) else { return fallback }
        return parsed
    }

    private func parseDouble(_ value: String?, fallback: Double) -> Double {
        guard let value, let parsed = Double(value) else { return fallback }
        return parsed
    }
}
