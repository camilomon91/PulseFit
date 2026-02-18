import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var profile: Profile

    private unowned let appState: AppState

    init(appState: AppState) {
        self.appState = appState
        self.profile = appState.profile
    }

    func save() {
        appState.profile = profile
    }
}
