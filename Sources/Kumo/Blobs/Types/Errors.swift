import Foundation

enum CacheDeserializationError<T>: Error {
    case initializationFailed(T.Type, data: Data, arguments: Any)
}

enum CacheSerializationError<T>: Error {
    case dataConversionFailed(T.Type, object: T, arguments: Any)
}
