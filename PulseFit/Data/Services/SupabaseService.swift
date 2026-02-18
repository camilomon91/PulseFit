import Foundation
import Supabase

protocol SupabaseService {
    var client: SupabaseClient { get }
}

struct DefaultSupabaseService: SupabaseService {
    let client: SupabaseClient

    static let shared = DefaultSupabaseService(client: supabase)
}
