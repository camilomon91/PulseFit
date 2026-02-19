import Foundation
import Supabase

final class SupabaseService {
    static let shared = SupabaseService()
    let client: SupabaseClient

    private init(client: SupabaseClient = supabase) {
        self.client = client
    }
}
