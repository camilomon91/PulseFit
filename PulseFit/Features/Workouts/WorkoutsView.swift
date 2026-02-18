import SwiftUI

struct WorkoutsView: View {
    @StateObject var viewModel: WorkoutsViewModel
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            List {
                Section("Programs") {
                    Text("Push / Pull / Legs")
                    Text("Upper / Lower")
                }

                Section("Exercise Library") {
                    ForEach(viewModel.exercises, id: \.id) { exercise in
                        VStack(alignment: .leading) {
                            Text(exercise.name)
                            Text(exercise.category).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Workouts")
            .task { await viewModel.load(userID: appState.profile.id) }
        }
    }
}
