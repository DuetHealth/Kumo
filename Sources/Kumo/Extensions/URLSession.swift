import Foundation

protocol InvalidationProtocol {
    func invalidate(session: URLSession, onInvalidation: @escaping (URLSession, Error?) -> Void)
}

final class URLSessionInvalidationDelegate: NSObject, URLSessionDelegate, InvalidationProtocol, @unchecked Sendable {
    fileprivate var invalidations = [URLSession: (URLSession, Error?) -> Void]()
    private let queue = DispatchQueue(label: "DuetHealth.Kumo.invalidations")

    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        queue.sync {
            invalidations[session]?(session, error)
            invalidations[session] = nil
        }
    }

    override func conforms(to aProtocol: Protocol) -> Bool {
        return protocol_isEqual(aProtocol, URLSessionTaskDelegate.self) || super.conforms(to: aProtocol)
    }

    func invalidate(session: URLSession, onInvalidation: @escaping (URLSession, Error?) -> Void) {
        queue.sync {
            invalidations[session] = onInvalidation
        }
    }
}

nonisolated(unsafe) private var temporaryDelegateKey = UInt8.max

extension URLSession {
    
    func finishTasksAndInvalidate(onInvalidation: @escaping (URLSession, Error?) -> Void) {
        guard let delegate = delegate as? InvalidationProtocol else { return }
        delegate.invalidate(session: self, onInvalidation: onInvalidation)
        finishTasksAndInvalidate()
    }
    
}
