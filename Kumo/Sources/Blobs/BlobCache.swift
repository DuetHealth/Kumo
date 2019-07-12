import Foundation
import RxSwift

public struct Percent: ExpressibleByFloatLiteral {
    public typealias FloatLiteralType = Float

    public static var oneQuarter: Percent {
        return 0.25
    }

    public static var half: Percent {
        return 0.5
    }

    public static var threeQuarters: Percent {
        return 0.75
    }


    private var value: Float

    public init(floatLiteral value: Float) {
        self.value = max(0, min(value, 1))
    }

}

extension Percent {

    public static var nearlyExpired: Percent {
        return 0.05
    }

}

public enum CacheLifetime {

    public enum ExtensionPolicy {

        case extendImmediately(by: DateComponents)

        /// Extends the lifetime of the cached object by the given time if
        ///
        case extendDuringLifetime(remaining: Percent, by: DateComponents)

        /// Extends the lifetime of the cached object by the given time if
        ///
        case extendWhenNearlyExpired(by: DateComponents)
    }

    case forever
    case sometimeFromNow(DateComponents)
    case sometimeFromReferenceDate(Date, DateComponents)
}

protocol StorageLocation {

}

public class Storage {

    public struct Heuristics {
        public var initialCacheLifetime = CacheLifetime.sometimeFromNow(DateComponents(day: 7))
        public var lifetimeExtensionPolicy = CacheLifetime.ExtensionPolicy?.none
    }

    let location: StorageLocation

    var heuristics = Heuristics()

    init(location: StorageLocation) {
        self.location = location
    }

}

struct Cache<Key: _ObjectiveCBridgeable, Member: AnyObject> {

}

struct ApplicationMemory: StorageLocation {

//    private let backingStorage = NSCache<String, >()



}

struct FileSystem: StorageLocation {

    private let backingManager: FileManager

    init() {
        self.backingManager = FileManager.default
    }

}

public class BlobCache {

    public let service: Service
    private let ephemeralStorage = Storage(location: ApplicationMemory())
    private let persistentStorage = Storage(location: FileSystem())

    public var ephemeralStorageHeuristics: Storage.Heuristics {
        get { return ephemeralStorage.heuristics }
        set { ephemeralStorage.heuristics = newValue }
    }

    public var persistentStorageHeuristics: Storage.Heuristics {
        get { return persistentStorage.heuristics }
        set { persistentStorage.heuristics = newValue }
    }

    public init(using service: Service) {
        self.service = service
    }

    public convenience init() {
        // TODO:
        fatalError("Implement no base URL on a service.")
    }

    public convenience init(baseURL: URL) {
        self.init(using: Service(baseURL: baseURL))
    }

    func fetch<D: FailableDataRepresentable>(from url: URL) -> Observable<D> {
        fatalError()
    }

    func fetch<D: ThrowingDataRepresentable>(from url: URL) -> Observable<D> {
        fatalError()
    }

}
