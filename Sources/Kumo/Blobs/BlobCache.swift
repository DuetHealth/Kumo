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

public class BlobCache {
    public let service: Service
    private let ephemeralStorage = Storage(location: InMemory(), heuristics: .inMemory)
    private let persistentStorage = Storage(location: FileSystem(), heuristics: .fileSystem)

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
        ephemeralStorage.fallback = persistentStorage
        #if canImport(UIKit)
            Observations.onMemoryWarning(invoke: #selector(cleanEphemeralStorage), on: self)
            Observations.onTermination(invoke: #selector(cleanPersistentStorage), on: self)
        #endif
    }

    public convenience init() {
        // TODO:
        fatalError("Implement no base URL on a service.")
    }

    public convenience init(baseURL: URL) {
        self.init(using: Service(baseURL: baseURL))
    }

    public func contains(_ url: URL) -> Bool {
        return ephemeralStorage.contains(url)
    }

    public func fetch<D: _DataConvertible & _DataRepresentable>(from url: URL) -> AnyPublisher<D, Error> where D._RepresentationArguments == Void, D._ConversionArguments == Void {
        return fetch(from: url, convertWith: (), representWith: ())
    }

    public func fetch<D: _DataConvertible & _DataRepresentable>(from url: URL, representWith representationArguments: D._RepresentationArguments) -> AnyPublisher<D, Error> where D._ConversionArguments == Void {
        return fetch(from: url, convertWith: (), representWith: representationArguments)
    }

    public func fetch<D: _DataConvertible & _DataRepresentable>(from url: URL, convertWith conversionArguments: D._ConversionArguments) -> AnyPublisher<D, Error> where D._RepresentationArguments == Void {
        return fetch(from: url, convertWith: conversionArguments, representWith: ())
    }

    public func fetch<D: _DataConvertible & _DataRepresentable>(from url: URL, convertWith conversionArguments: D._ConversionArguments, representWith representationArguments: D._RepresentationArguments) -> AnyPublisher<D, Error> {
        let downloadTask = service.perform(HTTP.Request.download(url))
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
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

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
}
