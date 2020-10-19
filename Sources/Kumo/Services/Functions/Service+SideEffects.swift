import Combine
import Foundation

public extension Service {

    struct SideEffectScope {

        let base: Service

        init(_ base: Service) {
            self.base = base
        }

        /// Perform the given request and ignore the result. Useful for "fire and forget" requests where failure is an okay
        /// option. The request is tied to the lifecycle of the `Service` performing the work and will be cancelled if the
        /// `Service` is deallocated.
        ///
        /// - Parameter request: the request to be performed.
        public func perform<Method: RequestMethod, Resource: RequestResource, Body: RequestBody, Parameters: RequestParameters, Key: ResponseNestedKey>(_ request: HTTP._Request<Method, Resource, Body, Parameters, Key>) {
            (base.perform(request) as AnyPublisher<Void, Error>)
                .sink(receiveCompletion: { _ in }, receiveValue: { })
                .withLifetime(of: base)
        }

    }

    /// Provides a convenient way for performing requests which are side effects; that is, requests for which
    /// observing the response is unnecessary.
    var unobserved: SideEffectScope {
        return SideEffectScope(self)
    }

}

