import Foundation

struct SupabaseConfig {
    let url: URL
    let anonKey: String
    let userID: UUID

    static func fromEnvironment() -> SupabaseConfig? {
        let env = ProcessInfo.processInfo.environment
        guard
            let urlString = env["SUPABASE_URL"],
            let key = env["SUPABASE_ANON_KEY"],
            let userIDString = env["SUPABASE_USER_ID"],
            let url = URL(string: urlString),
            let userID = UUID(uuidString: userIDString)
        else { return nil }

        return SupabaseConfig(url: url, anonKey: key, userID: userID)
    }
}

struct SupabaseRESTClient {
    let config: SupabaseConfig

    private func request(path: String, method: String = "GET", queryItems: [URLQueryItem] = [], body: Data? = nil, extraHeaders: [String: String] = [:]) throws -> URLRequest {
        var components = URLComponents(url: config.url.appendingPathComponent("rest/v1/\(path)"), resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems.isEmpty ? nil : queryItems

        guard let url = components?.url else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        request.setValue(config.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(config.anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("return=representation", forHTTPHeaderField: "Prefer")
        for (key, value) in extraHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        return request
    }

    func fetch<T: Decodable>(_ type: T.Type, path: String, queryItems: [URLQueryItem] = []) async throws -> T {
        let request = try request(path: path, queryItems: queryItems)
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    }

    func mutate<T: Decodable>(_ type: T.Type, path: String, method: String, queryItems: [URLQueryItem] = [], payload: some Encodable, extraHeaders: [String: String] = [:]) async throws -> T {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let body = try encoder.encode(payload)
        let request = try request(path: path, method: method, queryItems: queryItems, body: body, extraHeaders: extraHeaders)
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    }
}
