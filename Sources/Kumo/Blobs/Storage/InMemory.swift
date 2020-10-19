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
    private var queue = DispatchQueue(label: "key_queue")
    weak var delegate: StoragePruningDelegate?

    func fetch<D: _DataRepresentable>(for url: URL, arguments _: D._RepresentationArguments) throws -> D? {
        switch backingCache.object(forKey: murmur3_32(url.absoluteString) as NSString) {
        case .none:
            return nil
        case let .some(object) where object.value is D:
            if let newExpirationDate = delegate?.newExpirationDate(given: CachedObjectParameters(referenceDate: object.referenceDate, expirationDate: object.expirationDate)) {
                object.referenceDate = Date()
                object.expirationDate = newExpirationDate
            }
            return object.value as? D
        case let .some(object):
            throw StorageAccessError.typeMismatch(expected: D.self, found: object.value)
        }
    }

    func write<D: _DataConvertible>(_ object: D, from url: URL, arguments _: D._ConversionArguments) throws {
        queue.async { [weak self] in
            guard let self = self else { return }
            let cacheKey = murmur3_32(url.absoluteString)
            let expirationDate = self.delegate?.newExpirationDate(given: CachedObjectParameters()) ?? Date()
            self.backingCache.setObject(InMemory.Reference(key: cacheKey, value: object, expirationDate: expirationDate), forKey: cacheKey as NSString)
            self.keys.insert(cacheKey)
        }
    }

    func acquire<D: _DataRepresentable>(fromPath _: URL, origin _: URL, arguments _: D._RepresentationArguments) throws -> D? {
        return nil
    }

    func contains(_ url: URL) -> Bool {
        return keys.contains(murmur3_32(url.absoluteString))
    }

    func removeAll() {
        queue.async { [weak self] in
            guard let self = self else { return }
            self.backingCache.removeAllObjects()
            self.keys.removeAll()
        }
    }

    func pruneExpired() {
        queue.async { [weak self] in
            guard let self = self else { return }
            self.keys.filter {
                guard let reference = self.backingCache.object(forKey: $0 as NSString) else { return true }
                return reference.expirationDate < Date().addingTimeInterval(.ulpOfOne)
            }
            .forEach {
                self.keys.remove($0)
                self.backingCache.removeObject(forKey: $0 as NSString)
            }
        }
    }
}
