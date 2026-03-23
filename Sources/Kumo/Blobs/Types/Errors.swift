import Foundation

enum CacheDeserializationError<T>: Error, @unchecked Sendable {
    case initializationFailed(T.Type, data: Data, arguments: Any)
}

enum CacheSerializationError<T>: Error, @unchecked Sendable {
    case dataConversionFailed(T.Type, object: T, arguments: Any)
}
