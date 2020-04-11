import Foundation

struct MockResponse: Decodable {
    let args: [String: String]
    let headers: [String: String]
    let origin: String
    let url: URL
}

struct MockObjectResponse<O: Decodable>: Decodable {
    let args: [String: String]
    let headers: [String: String]
    let origin: String
    let json: O
    let url: URL
}
