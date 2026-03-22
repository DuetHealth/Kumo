import Foundation

struct RequestBody: Codable {

    struct NestedBody: Codable {
        let integer: Int
    }
    
    nonisolated(unsafe) static let dynamicBody: [String: Any] = ["nested": ["integer": 3], "leaf": "string"]

    let nested: NestedBody
    let leaf: String
    
}
