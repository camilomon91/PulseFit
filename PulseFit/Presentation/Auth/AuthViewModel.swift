import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isSignUp = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let signIn: SignInUseCase
    private let signUp: SignUpUseCase

    init(container: AppContainer) {
        self.signIn = SignInUseCase(authRepository: container.authRepository)
        self.signUp = SignUpUseCase(authRepository: container.authRepository)
    }

    func submit() async -> AuthSession? {
        isLoading = true
        defer { isLoading = false }
        do {
            if isSignUp {
                return try await signUp.execute(email: email, password: password)
            } else {
                return try await signIn.execute(email: email, password: password)
            }
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
