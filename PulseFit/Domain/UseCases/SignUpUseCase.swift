import Foundation

struct SignUpUseCase {
    let authRepository: AuthRepository

    func execute(email: String, password: String) async throws -> AuthSession {
        try await authRepository.signUp(email: email, password: password)
    }
}
