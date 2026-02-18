import Foundation

struct SignInUseCase {
    let authRepository: AuthRepository

    func execute(email: String, password: String) async throws -> AuthSession {
        try await authRepository.signIn(email: email, password: password)
    }
}
