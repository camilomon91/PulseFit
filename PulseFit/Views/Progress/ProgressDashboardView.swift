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
                .padding(16)
                .padding(.top, 8)
            }
            .neonScreenBackground()
            .navigationTitle("Progress")
            .sheet(item: Binding(
                get: { selectedDay.map { CalendarDay(date: $0) } },
                set: { value in selectedDay = value?.date }
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
            HStack(spacing: 10) {
                Button {
                    selectedMonth = calendar.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.85))
                        .frame(width: 34, height: 34)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.white.opacity(0.06))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Neon.stroke, lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(.plain)

                Spacer()

                Text(monthTitle(for: selectedMonth))
                    .font(.headline)
                    .foregroundStyle(Color.white)

                Spacer()

                Button {
                    selectedMonth = calendar.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.85))
                        .frame(width: 34, height: 34)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.white.opacity(0.06))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Neon.stroke, lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(.plain)
            }

            let days = daysForMonth(selectedMonth)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Color.white.opacity(0.55))
                }

                ForEach(days) { day in
                    if let date = day.date {
                        let hasCheckIn = !controller.checkIns(on: date).isEmpty
                        let dayNum = calendar.component(.day, from: date)

                        Button {
                            selectedDay = date
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(hasCheckIn ? Neon.neon.opacity(0.16) : Color.white.opacity(0.04))
                                    .overlay(
                                        Circle()
                                            .stroke(hasCheckIn ? Neon.neon.opacity(0.45) : Neon.stroke, lineWidth: 1)
                                    )

                                Text("\(dayNum)")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.white.opacity(0.95))
                            }
                            .frame(height: 38)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Color.clear.frame(height: 38)
                    }
                }
            }

            Text("Tap a day to view gym session details")
                .font(.caption)
                .foregroundStyle(Color.white.opacity(0.55))
        }
        .neonCard()
    }

    private func metricCard(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Neon.neon.opacity(0.18))
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Neon.neon)
                )
                .frame(width: 36, height: 36)

            Text(title)
                .foregroundStyle(Color.white.opacity(0.90))

            Spacer()

            Text(value)
                .font(.headline)
                .foregroundStyle(Color.white)
        }
        .neonCard()
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
