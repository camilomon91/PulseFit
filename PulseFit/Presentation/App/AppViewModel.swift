import Foundation
import Combine

@MainActor
final class AppViewModel: ObservableObject {
    @Published var session: AuthSession?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let observeSession: ObserveSessionUseCase

    init(container: AppContainer) {
        self.observeSession = ObserveSessionUseCase(authRepository: container.authRepository)
    }

    func bootstrap() async {
        isLoading = true
        defer { isLoading = false }
        do {
            session = try await observeSession.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
