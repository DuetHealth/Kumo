import Combine
import Foundation

#if canImport(UIKit)
import UIKit

fileprivate enum Observations {
    static func onMemoryWarning(invoke selector: Selector, on object: Any) {
        NotificationCenter.default.addObserver(object, selector: selector, name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }

    static func onTermination(invoke selector: Selector, on object: Any) {
        NotificationCenter.default.addObserver(object, selector: selector, name: UIApplication.willTerminateNotification, object: nil)
    }
}
#endif

/// A wrapper around a given ``service`` that provides ephemeral / persistent
/// caching for fetched requests. The ephemeral storage is checked first, then
/// the persistent storage, followed by the backing ``service``.
public class BlobCache {

    /// The backing service used when cached material can not be found.
    public let service: Service
    private let ephemeralStorage = Storage(location: InMemory(), heuristics: .inMemory)
    private let persistentStorage = Storage(location: FileSystem(), heuristics: .fileSystem)

    /// Policies / settings for cache storage to be reset from launch to launch.
    public var ephemeralStorageHeuristics: Storage.Heuristics {
        get { return ephemeralStorage.heuristics }
        set { ephemeralStorage.heuristics = newValue }
    }

    /// Policies / settings for persistent cache storage.
    public var persistentStorageHeuristics: Storage.Heuristics {
        get { return persistentStorage.heuristics }
        set { persistentStorage.heuristics = newValue }
    }

    /// Creates a blob cache object for the given `service`.
    /// - Parameter service: A backing service for fetch requests.
    public init(using service: Service) {
        self.service = service
        ephemeralStorage.fallback = persistentStorage
        #if canImport(UIKit)
            Observations.onMemoryWarning(invoke: #selector(cleanEphemeralStorage), on: self)
            Observations.onTermination(invoke: #selector(cleanPersistentStorage), on: self)
        #endif
    }

    /// Creates a blob cache object for a ``Service`` with no
    /// ``Service/baseURL``.
    public convenience init() {
        self.init(using: Service(baseURL: nil))
    }

    /// Creates a blob cache object for a ``Service`` configured with the given
    /// `baseURL`.
    /// - Parameter baseURL: The ``Service/baseURL`` for the backing
    /// ``service``.
    public convenience init(baseURL: URL?) {
        self.init(using: Service(baseURL: baseURL))
    }

    /// Checks whether the response for the given `url` is cached and available
    /// for immediate use.
    /// - Parameter url: The URL for the blob resource to be located.
    /// - Returns: A Boolean indicating whether the blob response for the `url`
    /// is available for immediate use (contained in the ephemeral storage).
    public func contains(_ url: URL) -> Bool {
        return ephemeralStorage.contains(url)
    }


    /// Retrieves a cached resource from the given `url`.
    /// - Parameter url: The URL for the blob resource to be located.
    /// - Returns: An object representing the data for the blob resource.
    public func cached<D: _DataConvertible & _DataRepresentable>(from url: URL) throws -> D? where D._RepresentationArguments == Void, D._ConversionArguments == Void {
        try ephemeralStorage.fetch(for: url, convertWith: (), representWith: ())
    }

    /// Retrieves a cached resource from the given `url`.
    /// - Parameters:
    ///   - url: The URL for the blob resource to be located.
    ///   - conversionArguments: Arguments to be used to convert the
    /// blob data.
    ///   - representationArguments: Arguments to be used to construct
    /// the representing object.
    /// - Returns: An object representing the data for the blob resource.
    public func cached<D: _DataConvertible & _DataRepresentable>(from url: URL, convertWith conversionArguments: D._ConversionArguments, representWith representationArguments: D._RepresentationArguments) throws -> D? {
        try ephemeralStorage.fetch(for: url, convertWith: conversionArguments, representWith: representationArguments)
    }

    /// Retrieves the blob resource from the given `url`. If a cached response
    /// exists and has not expired it will be returned instead of re-fetching
    /// the response.
    /// - Parameter url: The URL for the blob resource to be located.
    /// - Returns: A publisher for an object representing the data for the
    /// blob resource at the `url`.
    public func fetch<D: _DataConvertible & _DataRepresentable>(from url: URL) -> AnyPublisher<D, Error> where D._RepresentationArguments == Void, D._ConversionArguments == Void {
        return fetch(from: url, convertWith: (), representWith: ())
    }

    /// Retrieves the blob resource from the given `url`. If a cached response
    /// exists and has not expired it will be returned instead of re-fetching
    /// the response.
    /// - Parameters:
    ///   - url: The URL for the blob resource to be located.
    ///   - representationArguments: Arguments to be used to construct
    /// the representing object.
    /// - Returns: A publisher for an object representing the data for the
    /// blob resource at the `url`.
    public func fetch<D: _DataConvertible & _DataRepresentable>(from url: URL, representWith representationArguments: D._RepresentationArguments) -> AnyPublisher<D, Error> where D._ConversionArguments == Void {
        return fetch(from: url, convertWith: (), representWith: representationArguments)
    }

    /// Retrieves the blob resource from the given `url`. If a cached response
    /// exists and has not expired it will be returned instead of re-fetching
    /// the response.
    /// - Parameters:
    ///   - url: The URL for the blob resource to be located.
    ///   - conversionArguments: Arguments to be used to convert the
    /// blob data.
    /// - Returns: A publisher for an object representing the data for the
    /// blob resource at the `url`.
    public func fetch<D: _DataConvertible & _DataRepresentable>(from url: URL, convertWith conversionArguments: D._ConversionArguments) -> AnyPublisher<D, Error> where D._RepresentationArguments == Void {
        return fetch(from: url, convertWith: conversionArguments, representWith: ())
    }


    /// Retrieves the blob resource from the given `url`. If a cached response
    /// exists and has not expired it will be returned instead of re-fetching
    /// the response.
    /// - Parameters:
    ///   - url: The URL for the blob resource to be located.
    ///   - conversionArguments: Arguments to be used to convert the
    /// blob data.
    ///   - representationArguments: Arguments to be used to construct
    /// the representing object.
    /// - Returns: A publisher for an object representing the data for the
    /// blob resource at the `url`.
    public func fetch<D: _DataConvertible & _DataRepresentable>(from url: URL, convertWith conversionArguments: D._ConversionArguments, representWith representationArguments: D._RepresentationArguments) -> AnyPublisher<D, Error> {
        let downloadTask = fetch(from: url)
            .flatMap { [self] downloadPath -> AnyPublisher<D, Error> in
                do {
                    if let data: D = try self.ephemeralStorage.acquire(fromPath: downloadPath, origin: url, convertWith: conversionArguments, representWith: representationArguments) {
                        return Just(data)
                            .setFailureType(to: Error.self)
                            .eraseToAnyPublisher()
                    }
                    return Empty(completeImmediately: true)
                        .eraseToAnyPublisher()
                } catch {
                    return Fail(error: error)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()

        return Deferred<Future<D?, Error>> {
            Future<D?, Error> { [self] promise in
                do {
                    promise(.success(try self.ephemeralStorage.fetch(for: url, convertWith: conversionArguments, representWith: representationArguments)))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .flatMap { (data: D?) -> AnyPublisher<D, Error> in
            if let data = data {
                return Just(data)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            } else {
                return downloadTask
            }
        }
        .eraseToAnyPublisher()
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    /// Cleans both ephemeral and persistent storage immediately.
    public func cleanImmediately() {
        cleanEphemeralStorage()
        cleanPersistentStorage()
    }

    @objc private func cleanEphemeralStorage() {
        ephemeralStorage.clean()
    }

    @objc private func cleanPersistentStorage() {
        persistentStorage.clean()
    }

    private func fetch(from url: URL) -> AnyPublisher<URL, Error> {
        Deferred<AnyPublisher<URL, Error>> {
            Future<URL, Error> { [self] promise in
                Task {
                    do {
                        let downloadPath = try await service.perform(HTTP.Request.download(url))
                        promise(.success(downloadPath))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }.eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
}
