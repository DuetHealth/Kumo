import Foundation

class InMemory: StorageLocation {

    private class Reference {

        let key: String
        let value: Any
        var referenceDate = Date()
        var expirationDate: Date

        init(key: String, value: Any, expirationDate: Date) {
            self.key = key
            self.value = value
            referenceDate = Date()
            self.expirationDate = expirationDate
        }
    }

    private let backingCache = NSCache<NSString, Reference>()

    private var keys = Set<String>()
    var cachePathResolver: CachePathResolver = .sha256
    weak var delegate: StoragePruningDelegate?

    func fetch<D: _DataRepresentable>(for url: URL, arguments: D._RepresentationArguments) throws -> D? {
        switch backingCache.object(forKey: cachePathResolver.path(for: url.absoluteString) as NSString) {
        case .none:
            return nil
        case .some(let object) where object.value is D:
            if let newExpirationDate = delegate?.newExpirationDate(given: CachedObjectParameters.init(referenceDate: object.referenceDate, expirationDate: object.expirationDate)) {
                object.referenceDate = Date()
                object.expirationDate = newExpirationDate
            }
            return object.value as? D
        case .some(let object):
            throw StorageAccessError.typeMismatch(expected: D.self, found: object.value)
        }
    }

    func write<D: _DataConvertible>(_ object: D, from url: URL, arguments: D._ConversionArguments) throws {
        let cacheKey = cachePathResolver.path(for: url.absoluteString)
        let expirationDate = delegate?.newExpirationDate(given: CachedObjectParameters()) ?? Date()
        backingCache.setObject(InMemory.Reference(key: cacheKey, value: object, expirationDate: expirationDate), forKey: cacheKey as NSString)
        keys.insert(cacheKey)
    }

    func acquire<D: _DataRepresentable>(fromPath path: URL, origin url: URL, arguments: D._RepresentationArguments) throws -> D? {
        return nil
    }

    func contains(_ url: URL) -> Bool {
        return keys.contains(cachePathResolver.path(for: url.absoluteString))
    }

    func removeAll() {
        backingCache.removeAllObjects()
        keys.removeAll()
    }

    func pruneExpired() {
        keys.filter {
            guard let reference = backingCache.object(forKey: $0 as NSString) else { return true }
            return reference.expirationDate < Date().addingTimeInterval(.ulpOfOne)
        }
            .forEach {
                keys.remove($0)
                backingCache.removeObject(forKey: $0 as NSString)
            }
    }

}
