import Combine
import Foundation
import SystemConfiguration

/// The network connectivity status.
public enum NetworkConnectivity {

    /// The status has not yet been determined.
    case unknown

    /// The device is not connected to the internet.
    case notConnected

    /// The device is connected to the internet through WWAN (wireless wide
    /// area network).
    case wwan

    /// The device is connected to the internet.
    case internet

}

/// A base class that implements standardized access to a specific set of
/// services and exposes a publisher ``networkConnectivity`` to monitor network
/// connectivity.
open class ApplicationLayer {
    
    private var commonHeaders = [String: String]()
    private let services: [ServiceKey: Service]

    private let networkConnectivitySubject: CurrentValueSubject<NetworkConnectivity, Never> = .init(.unknown)

    /// A publisher that updates with the current network connectivity status
    /// for the device.
    public var networkConnectivity: AnyPublisher<NetworkConnectivity, Never> {
        networkConnectivitySubject.removeDuplicates().eraseToAnyPublisher()
    }

    /// Creates an application layer backed by the set of service key → service
    /// pairs.
    public init(with services: [ServiceKey: Service] = [:]) {
        self.services = services
        
        var address = sockaddr_in()
        address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        address.sin_family = sa_family_t(AF_INET)
        withUnsafePointer(to: &address) { pointer in
            pointer.withMemoryRebound(to: sockaddr.self, capacity: MemoryLayout<sockaddr>.size) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }
        .map { [unowned self] in self.publishReachability($0) }?
        .sink(receiveValue: { [unowned self] in self.networkConnectivitySubject.send($0) })
        .withLifetime(of: self)
    }

    /// Retrieves the service for a given `key`.
    /// - Remark: Caller must ensure that the `key` exists for this application
    /// layer.
    public subscript(_ key: ServiceKey) -> Service {
        return services[key]!
    }

    private func publishReachability(_ reachability: SCNetworkReachability) -> AnyPublisher<NetworkConnectivity, Never> {
        AnyPublisher.create { subscriber in
            var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
            context.info = Unmanaged.passRetained(AnyObserverReference<NetworkConnectivity, Never>(subscriber)).toOpaque()
            SCNetworkReachabilitySetCallback(reachability, { _, flags, info in
                guard let observer = info.map({ Unmanaged<AnyObserverReference<NetworkConnectivity, Never>>.fromOpaque($0).takeUnretainedValue() }) else { return }
                if flags.isReachable {
                    #if os(iOS)
                    observer.base.onNext(flags.contains(.isWWAN) ? .wwan : .internet)
                    #else
                    observer.base.onNext(.internet)
                    #endif
                } else {
                    observer.base.onNext(.notConnected)
                }
            }, &context)
            SCNetworkReachabilitySetDispatchQueue(reachability, DispatchQueue.main)
            return AnyCancellable() {
                SCNetworkReachabilitySetCallback(reachability, nil, nil)
                SCNetworkReachabilitySetDispatchQueue(reachability, nil)
            }
        }
    }
    
}

private class AnyObserverReference<Input, Failure> where Failure: Error {

    let base: AnyObserver<Input, Failure>

    init(_ base: AnyObserver<Input, Failure>) {
        self.base = base
    }

}

private extension SCNetworkReachabilityFlags {

    var isReachable: Bool {
        let canConnectAutomatically = contains(.connectionOnDemand) || contains(.connectionOnTraffic) && !contains(.interventionRequired)
        return contains(.reachable)
            && (!contains(.connectionRequired) || canConnectAutomatically)
    }

}
