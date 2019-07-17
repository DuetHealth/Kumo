import Foundation

public enum StorageAccessError<T>: Error {
    case typeMismatch(expected: T.Type, found: Any)
}

struct CachedObjectParameters {
    let referenceDate: Date
    let expirationDate: Date?

    init(referenceDate: Date = Date(), expirationDate: Date? = nil) {
        self.referenceDate = referenceDate
        self.expirationDate = expirationDate
    }

}

protocol StoragePruningDelegate: AnyObject {
    func newExpirationDate(given parameters: CachedObjectParameters) -> Date?
}

protocol StorageLocation: AnyObject {
    var delegate: StoragePruningDelegate? { get set }
    func fetch<D: _DataRepresentable>(for url: URL, arguments: D._RepresentationArguments) throws -> D?
    func write<D: _DataConvertible>(_ object: D, from url: URL, arguments: D._ConversionArguments) throws
    func acquire<D: _DataRepresentable>(fromPath path: URL, origin url: URL, arguments: D._RepresentationArguments) throws -> D?
    func pruneExpired()
    func removeAll()
}
