import Combine
import Foundation

public extension Service {
    
    struct SideEffectScope {
        
        let base: Service
        
        init(_ base: Service) {
            self.base = base
        }

        @discardableResult public func perform<Method: RequestMethod, Resource: RequestResource, Body: RequestBody, Parameters: RequestParameters, Key: ResponseNestedKey>(_ request: HTTP._Request<Method, Resource, Body, Parameters, Key>) -> Cancellable {
            // TODO: test that this doesn't immediately get cancelled.
            return (base.perform(request) as AnyPublisher<Void, Error>).sink(receiveCompletion: { _ in }, receiveValue: { })
        }

    }
    
    /// Provides a convenient way for performing requests which are side effects; that is, requests for which
    /// observing the response is unnecessary.
    var unobserved: SideEffectScope {
        return SideEffectScope(self)
    }
    
}
