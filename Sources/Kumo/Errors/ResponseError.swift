import Foundation

#if canImport(KumoCoding)
import KumoCoding
#endif

public struct ResponseError {
    
    let type: (Error & Decodable).Type
    private let implementation: (Data, RequestDecoding) throws -> Error
    
    public init<T: Error & Decodable>(_ type: T.Type) {
        self.type = type
        implementation = { data, decoding in
            try decoding.decode(T.self, from: data)
        }
    }
    
    func decode(data: Data, with decoding: RequestDecoding) throws -> Error {
        return try implementation(data, decoding)
    }
    
}
