import Foundation

struct ObserveSessionUseCase {
    let authRepository: AuthRepository

    func execute() async throws -> AuthSession? {
        try await authRepository.currentSession()
    }
}
