import Foundation

public protocol RequestDecoding {
    var acceptType: MIMEType { get }
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}

extension JSONDecoder: RequestDecoding {
    
    public var acceptType: MIMEType {
        return .applicationJSON(charset: .utf8)
    }
    
}
