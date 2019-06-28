import Foundation

public extension CodingUserInfoKey {
    static let xmlNamespaces = CodingUserInfoKey(rawValue: #function)!
}

public struct XMLNamespace {
    public let prefix: String
    public let uri: String?

    public var attributeName: String {
        return "xmlns:\(prefix)"
    }

    public init(prefix: String, uri: String? = nil) {
        self.prefix = prefix
        self.uri = uri
    }

}
