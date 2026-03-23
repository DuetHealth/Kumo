@preconcurrency import Combine
import Foundation
import Network

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

    private let services: [ServiceKey: Service]

    private let networkConnectivitySubject: CurrentValueSubject<NetworkConnectivity, Never> = .init(.unknown)
    private let pathMonitor = NWPathMonitor()

    /// A publisher that updates with the current network connectivity status
    /// for the device.
    public var networkConnectivity: AnyPublisher<NetworkConnectivity, Never> {
        networkConnectivitySubject.removeDuplicates().eraseToAnyPublisher()
    }

    /// Creates an application layer backed by the set of service key → service
    /// pairs.
    public init(with services: [ServiceKey: Service] = [:]) {
        self.services = services

        let subject = networkConnectivitySubject
        pathMonitor.pathUpdateHandler = { path in
            let connectivity: NetworkConnectivity
            switch path.status {
            case .satisfied:
                #if os(iOS)
                connectivity = path.isExpensive ? .wwan : .internet
                #else
                connectivity = .internet
                #endif
            case .unsatisfied, .requiresConnection:
                connectivity = .notConnected
            @unknown default:
                connectivity = .unknown
            }
            subject.send(connectivity)
        }
        pathMonitor.start(queue: DispatchQueue(label: "DuetHealth.Kumo.networkMonitor"))
    }

    deinit {
        pathMonitor.cancel()
    }

    /// Retrieves the service for a given `key`.
    /// - Remark: Caller must ensure that the `key` exists for this application
    /// layer.
    public subscript(_ key: ServiceKey) -> Service {
        return services[key]!
    }

}
