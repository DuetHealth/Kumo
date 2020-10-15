import Combine
import Foundation
import SystemConfiguration

public enum NetworkConnectivity {
    case unknown
    case notConnected
    case wwan
    case internet
}

open class ApplicationLayer {
    
    private var commonHeaders = [String: String]()
    private var services = [ServiceKey: Service]()

    private let networkConnectivitySubject: CurrentValueSubject<NetworkConnectivity, Never> = .init(.unknown)

    public var networkConnectivity: AnyPublisher<NetworkConnectivity, Never> {
        networkConnectivitySubject.removeDuplicates().eraseToAnyPublisher()
    }

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
        .map { [unowned self] in self.observeReachability($0) }?
        .sink(receiveValue: { [unowned self] in self.networkConnectivitySubject.send($0) })
        .withLifetime(of: self)
    }
    
    public subscript(_ key: ServiceKey) -> Service {
        return services[key]!
    }

    private func observeReachability(_ reachability: SCNetworkReachability) -> AnyPublisher<NetworkConnectivity, Never> {
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
