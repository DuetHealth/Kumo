import Foundation
import RxCocoa
import RxSwift
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
    
    private let networkConnectivityRelay = BehaviorRelay(value: NetworkConnectivity.unknown)
    
    public var networkConnectivity: Observable<NetworkConnectivity> {
        return networkConnectivityRelay
            .distinctUntilChanged()
    }
    
    private let bag = DisposeBag()
    
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
            .debug()
            .bind(to: networkConnectivityRelay)
            .disposed(by: bag)
    }
    
    public subscript(_ key: ServiceKey) -> Service {
        return services[key]!
    }
    
    private func observeReachability(_ reachability: SCNetworkReachability) -> Observable<NetworkConnectivity> {
        return Observable<NetworkConnectivity>.create { [reachability] observer -> Disposable in
            var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
            context.info = Unmanaged.passRetained(ObserverReference(observer)).toOpaque()
            SCNetworkReachabilitySetCallback(reachability, { _, flags, info in
                guard let observer = info.map({ Unmanaged<ObserverReference<NetworkConnectivity>>.fromOpaque($0).takeUnretainedValue() }) else { return }
                if flags.isReachable { observer.base.onNext(flags.contains(.isWWAN) ? .wwan : .internet) }
                else { observer.base.onNext(.notConnected) }
            }, &context)
            SCNetworkReachabilitySetDispatchQueue(reachability, DispatchQueue.main)
            return Disposables.create {
                SCNetworkReachabilitySetCallback(reachability, nil, nil)
                SCNetworkReachabilitySetDispatchQueue(reachability, nil)
            }
        }
    }
    
}

fileprivate class ObserverReference<Element> {
    
    let base: AnyObserver<Element>
    
    init(_ base: AnyObserver<Element>) {
        self.base = base
    }
    
}

fileprivate extension SCNetworkReachabilityFlags {
    
    var isReachable: Bool {
        let canConnectAutomatically = contains(.connectionOnDemand) || contains(.connectionOnTraffic) && !contains(.interventionRequired)
        return contains(.reachable)
            && (!contains(.connectionRequired) || canConnectAutomatically)
    }
    
}
