import Foundation

public enum Authorization {

    case basic(username: String, password: String)
    case bearer(String)

    public var value: String {
        switch self {
        case .basic(username: let username, password: let password):
            return "Basic: " + ("\(username):\(password)".data(using: .utf8).map { $0.base64EncodedString() } ?? "")
        case .bearer(let token):
            return "Bearer: \(token)"
        }
    }

}
