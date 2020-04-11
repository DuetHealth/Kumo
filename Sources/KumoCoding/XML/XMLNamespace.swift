import Foundation

public extension CodingUserInfoKey {
    static var xmlNamespaces:CodingUserInfoKey {
        return CodingUserInfoKey(rawValue: #function)!
    }

    static var rootNamespace: CodingUserInfoKey {
        return CodingUserInfoKey(rawValue: #function)!
    }
}

public struct XMLNamespace {
    public let prefix: String
    public let uri: String?

    public var attributeName: String {
        return prefix.isEmpty ? "xmlns" : "xmlns:\(prefix)"
    }

    public init(prefix: String, uri: String? = nil) {
        self.prefix = prefix
        self.uri = uri
    }

}
