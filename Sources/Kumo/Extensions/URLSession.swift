import Foundation

protocol InvalidationProtocol {
    func invalidate(session: URLSession, onInvalidation: @escaping (URLSession, Error?) -> Void)
}

class URLSessionInvalidationDelegate: NSObject, URLSessionDelegate, InvalidationProtocol {
    fileprivate var invalidations = [URLSession: (URLSession, Error?) -> Void]()

    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        invalidations[session]?(session, error)
        invalidations.removeValue(forKey: session)
    }

    override func conforms(to aProtocol: Protocol) -> Bool {
        return protocol_isEqual(aProtocol, URLSessionTaskDelegate.self) || super.conforms(to: aProtocol)
    }

    func invalidate(session: URLSession, onInvalidation: @escaping (URLSession, Error?) -> Void) {
        invalidations[session] = onInvalidation
    }
}

class URLSessionThreadSafeInvalidationDelegate: NSObject, URLSessionDelegate, InvalidationProtocol {
    fileprivate var invalidations = [URLSession: (URLSession, Error?) -> Void]()
    var invalidationQueue = DispatchQueue(label: "DuetHealth.Kumo.invalidations")

    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        invalidationQueue.sync {
            invalidations[session]?(session, error)
            invalidations[session] = nil
        }
    }

    override func conforms(to aProtocol: Protocol) -> Bool {
        return protocol_isEqual(aProtocol, URLSessionTaskDelegate.self) || super.conforms(to: aProtocol)
    }

    func invalidate(session: URLSession, onInvalidation: @escaping (URLSession, Error?) -> Void) {
        invalidationQueue.sync {
            invalidations[session] = onInvalidation
        }
    }
}

fileprivate var temporaryDelegateKey = UInt8.max

extension URLSession {
    
    func finishTasksAndInvalidate(onInvalidation: @escaping (URLSession, Error?) -> Void) {
        guard let delegate = delegate as? InvalidationProtocol else { return }
        delegate.invalidate(session: self, onInvalidation: onInvalidation)
        finishTasksAndInvalidate()
    }
    
}
