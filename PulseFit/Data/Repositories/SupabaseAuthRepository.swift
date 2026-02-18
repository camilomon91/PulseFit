import Foundation
import Supabase

final class SupabaseAuthRepository: AuthRepository {
    private let service: SupabaseService

    init(service: SupabaseService) {
        self.service = service
    }

    func currentSession() async throws -> AuthSession? {
        guard let session = try await service.client.auth.session else { return nil }
        return AuthSession(userID: session.user.id, email: session.user.email ?? "", accessToken: session.accessToken)
    }

    func signIn(email: String, password: String) async throws -> AuthSession {
        let response = try await service.client.auth.signIn(email: email, password: password)
        return AuthSession(userID: response.user.id, email: response.user.email ?? email, accessToken: response.accessToken)
    }

    func signUp(email: String, password: String) async throws -> AuthSession {
        let response = try await service.client.auth.signUp(email: email, password: password)
        return AuthSession(userID: response.user.id, email: response.user.email ?? email, accessToken: response.accessToken)
    }

    func signOut() async throws {
        try await service.client.auth.signOut()
    }
}
