import SwiftUI

struct ProgressDashboardView: View {
    @ObservedObject var controller: ProgressController

    @State private var selectedMonth = Date()
    @State private var selectedDay: Date?

    private let calendar = Calendar.current

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    metricCard(title: "Workouts Completed", value: "\(controller.snapshot.workoutsCompleted)", icon: "checkmark.circle.fill")
                    metricCard(title: "Sets Logged", value: "\(controller.snapshot.setsLogged)", icon: "list.number")
                    metricCard(title: "Volume", value: "\(controller.snapshot.totalVolumeKg, default: "%.0f") kg", icon: "scalemass")
                    metricCard(title: "Meals Tracked", value: "\(controller.snapshot.mealsLogged)", icon: "fork.knife.circle")

                    calendarCard
                }
                .padding()
            }
            .navigationTitle("Progress")
            .sheet(item: Binding(
                get: {
                    selectedDay.map { CalendarDay(date: $0) }
                },
                set: { value in
                    selectedDay = value?.date
                }
            )) { day in
                DayDetailSheet(
                    day: day.date,
                    checkIns: controller.checkIns(on: day.date),
                    workoutsById: controller.workoutsById
                )
            }
        }
    }

    private var calendarCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button {
                    selectedMonth = calendar.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
                } label: {
                    Image(systemName: "chevron.left")
                }

                Spacer()
                Text(monthTitle(for: selectedMonth)).font(.headline)
                Spacer()

                Button {
                    selectedMonth = calendar.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
                } label: {
                    Image(systemName: "chevron.right")
                }
            }

            let days = daysForMonth(selectedMonth)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { symbol in
                    Text(symbol).font(.caption).foregroundStyle(.secondary)
                }

                ForEach(days) { day in
                    if let date = day.date {
                        let hasCheckIn = !controller.checkIns(on: date).isEmpty
                        Button {
                            selectedDay = date
                        } label: {
                            VStack(spacing: 4) {
                                Text("\(calendar.component(.day, from: date))")
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity)
                                Circle()
                                    .fill(hasCheckIn ? Color.green : Color.clear)
                                    .frame(width: 6, height: 6)
                            }
                            .padding(.vertical, 6)
                            .background(hasCheckIn ? Color.green.opacity(0.15) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    } else {
                        Color.clear.frame(height: 32)
                    }
                }
            }

            Text("Tap a day to view gym session details")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .glassCard()
    }

    private func metricCard(title: String, value: String, icon: String) -> some View {
        HStack {
            Label(title, systemImage: icon)
            Spacer()
            Text(value).font(.headline)
        }
        .glassCard()
    }

    private func monthTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    private func daysForMonth(_ month: Date) -> [CalendarCellDay] {
        guard let interval = calendar.dateInterval(of: .month, for: month),
              let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: interval.start),
              let lastWeekStart = calendar.dateInterval(of: .weekOfMonth, for: interval.end.addingTimeInterval(-1))?.start,
              let lastWeek = calendar.dateInterval(of: .weekOfMonth, for: lastWeekStart)
        else {
            return []
        }

        let gridStart = firstWeek.start
        let gridEnd = lastWeek.end

        var days: [CalendarCellDay] = []
        var current = gridStart

        while current < gridEnd {
            if calendar.isDate(current, equalTo: month, toGranularity: .month) {
                days.append(CalendarCellDay(date: current))
            } else {
                days.append(CalendarCellDay(date: nil))
            }
            current = calendar.date(byAdding: .day, value: 1, to: current) ?? current
        }

        return days
    }
}

private struct CalendarCellDay: Identifiable {
    let id = UUID()
    let date: Date?
}

private struct CalendarDay: Identifiable {
    let id = UUID()
    let date: Date
}

private struct DayDetailSheet: View {
    let day: Date
    let checkIns: [GymCheckIn]
    let workoutsById: [UUID: Workout]

    var body: some View {
        NavigationStack {
            List {
                if checkIns.isEmpty {
                    Text("No gym activity recorded for this day.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(checkIns) { checkIn in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(workoutsById[checkIn.workoutId]?.name ?? "Workout")
                                .font(.headline)
                            Text("Started: \(checkIn.startedAt.formatted(date: .omitted, time: .shortened))")
                                .font(.subheadline)
                            if let completedAt = checkIn.completedAt {
                                Text("Finished: \(completedAt.formatted(date: .omitted, time: .shortened))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("Session not finished")
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                            }
                        }
                    }
                }
            }
            .navigationTitle(day.formatted(date: .abbreviated, time: .omitted))
        }
    }
}
