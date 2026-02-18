import Foundation

struct AuthSession: Equatable {
    let userID: UUID
    let email: String
    let accessToken: String
}
