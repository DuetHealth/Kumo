import Foundation

public struct HTTPHeader: Hashable {
    
    public static let accept = HTTPHeader(rawValue: "Accept")
    public static let acceptLanguage = HTTPHeader(rawValue: "Accept-Language")
    public static let authorization = HTTPHeader(rawValue: "Authorization")
    public static let contentType = HTTPHeader(rawValue: "Content-Type")
    public static let contentLength = HTTPHeader(rawValue: "Content-Length")
    
    public static func custom(_ value: String) -> HTTPHeader {
        return HTTPHeader(rawValue: value)
    }
    
    let rawValue: String
    
    init(rawValue: String) {
        self.rawValue = rawValue
    }
    
}
