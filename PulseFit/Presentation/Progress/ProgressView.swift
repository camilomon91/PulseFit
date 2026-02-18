import SwiftUI
import Charts

struct ProgressViewScreen: View {
    let snapshots: [ProgressSnapshot]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                GlassCard {
                    Text("Total Training Volume")
                        .font(.headline)
                    Chart(snapshots) { snapshot in
                        BarMark(
                            x: .value("Day", snapshot.day),
                            y: .value("Volume", snapshot.totalVolume)
                        )
                    }
                    .frame(height: 220)
                }

                GlassCard {
                    Text("Sets Completed")
                        .font(.headline)
                    Chart(snapshots) { snapshot in
                        LineMark(
                            x: .value("Day", snapshot.day),
                            y: .value("Sets", snapshot.setsCompleted)
                        )
                    }
                    .frame(height: 220)
                }
            }
            .padding()
        }
        .navigationTitle("Progress")
    }
}
