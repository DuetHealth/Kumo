import Foundation

struct Authenticate: Codable, Equatable {
    let username: String
    let password: String
    let deviceID: String
    let appID: String
}
