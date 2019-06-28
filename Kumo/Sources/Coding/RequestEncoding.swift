import Foundation

public protocol RequestEncoding {
    var contentType: MIMEType { get }
    func encode<T: Encodable>(_ value: T) throws -> Data
}

extension JSONEncoder: RequestEncoding {
    
    public var contentType: MIMEType {
        return .applicationJSON(charset: .utf8)
    }
    
}
