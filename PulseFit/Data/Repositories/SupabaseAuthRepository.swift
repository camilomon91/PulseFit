import Foundation
import Supabase

final class SupabaseAuthRepository: AuthRepository {
    private let service: SupabaseService

    init(service: SupabaseService) {
        self.service = service
    }

    func currentSession() async throws -> AuthSession? {
        do {
            let session = try await service.client.auth.session
            return AuthSession(
                userID: session.user.id,
                email: session.user.email ?? "",
                accessToken: session.accessToken
            )
        } catch {
            return nil
        }
    }

    func signIn(email: String, password: String) async throws -> AuthSession {
        let response = try await service.client.auth.signIn(email: email, password: password)
        if let session = response.session {
            return AuthSession(
                userID: session.user.id,
                email: session.user.email ?? email,
                accessToken: session.accessToken
            )
        }

        let session = try await service.client.auth.session
        return AuthSession(
            userID: session.user.id,
            email: session.user.email ?? email,
            accessToken: session.accessToken
        )
    }

    func signUp(email: String, password: String) async throws -> AuthSession {
        let response = try await service.client.auth.signUp(email: email, password: password)

        if let session = response.session {
            return AuthSession(
                userID: session.user.id,
                email: session.user.email ?? email,
                accessToken: session.accessToken
            )
        }

        if let user = response.user {
            return AuthSession(userID: user.id, email: user.email ?? email, accessToken: "")
        }

        throw AuthRepositoryError.missingAuthIdentity
    }

    func signOut() async throws {
        try await service.client.auth.signOut()
    }
}

private enum AuthRepositoryError: LocalizedError {
    case missingAuthIdentity

    var errorDescription: String? {
        switch self {
        case .missingAuthIdentity:
            return "Supabase did not return a user or session."
        }
    }
}
