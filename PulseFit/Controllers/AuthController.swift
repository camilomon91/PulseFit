import Foundation
import Combine

@MainActor
final class AuthController: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    var onAuthStateChanged: ((Bool) -> Void)?
    private let authService = AuthService()

    func loadSession() async {
        do {
            _ = try await authService.currentSession()
            onAuthStateChanged?(true)
        } catch {
            onAuthStateChanged?(false)
        }
    }

    func signIn() async {
        await performAuthAction { try await authService.signIn(email: email, password: password) }
    }

    func signUp() async {
        await performAuthAction { try await authService.signUp(email: email, password: password) }
    }

    func signOut() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await authService.signOut()
            onAuthStateChanged?(false)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func performAuthAction(_ action: () async throws -> Void) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await action()
            onAuthStateChanged?(true)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
