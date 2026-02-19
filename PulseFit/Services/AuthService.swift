import Foundation
import Supabase

final class AuthService {
    private let client = SupabaseService.shared.client

    func currentSession() async throws -> Session {
        try await client.auth.session
    }

    func signIn(email: String, password: String) async throws {
        _ = try await client.auth.signIn(email: email, password: password)
    }

    func signUp(email: String, password: String) async throws {
        _ = try await client.auth.signUp(email: email, password: password)
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }
}
