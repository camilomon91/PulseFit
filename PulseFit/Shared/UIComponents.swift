import SwiftUI

struct GoalCard: View {
    let title: String
    let subtitle: String
    let isComplete: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title).font(.headline)
                Spacer()
                Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isComplete ? .green : .secondary)
            }
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct MacroProgressRow: View {
    let name: String
    let consumed: Int
    let goal: Int
    var emphasize: Bool = false

    var progress: Double {
        guard goal > 0 else { return 0 }
        return min(1.0, Double(consumed) / Double(goal))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(name).font(emphasize ? .headline : .subheadline)
                Spacer()
                Text("\(consumed)/\(goal)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: progress)
                .tint(emphasize ? .orange : .blue)
        }
    }
}
