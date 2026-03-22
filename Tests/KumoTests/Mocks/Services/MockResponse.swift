import Foundation

struct MockResponse: Decodable, Sendable {
    let args: [String: String]
    let headers: [String: String]
    let origin: String
    let url: URL
}

struct MockObjectResponse<O: Decodable & Sendable>: Decodable, Sendable {
    let args: [String: String]
    let headers: [String: String]
    let origin: String
    let json: O
    let url: URL
}
