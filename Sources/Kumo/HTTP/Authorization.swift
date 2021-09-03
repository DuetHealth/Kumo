import Foundation

/// An enumeration representing a requests's authentication header.
public enum Authorization {

    /// Basic access authentication through credentials.
    case basic(username: String, password: String)

    /// Bearer / token authentication.
    case bearer(String)

    /// The value of the authorization header.
    public var value: String {
        switch self {
        case .basic(username: let username, password: let password):
            return "Basic " + ("\(username):\(password)".data(using: .utf8).map { $0.base64EncodedString() } ?? "")
        case .bearer(let token):
            return "Bearer \(token)"
        }
    }

}
