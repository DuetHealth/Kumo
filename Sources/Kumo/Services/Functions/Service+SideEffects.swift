import Combine
import Foundation

public extension Service {

    /// Defines a scope for requests that do not require verification of
    /// fulfillment.
    struct SideEffectScope {

        let base: Service

        init(_ base: Service) {
            self.base = base
        }

        /// Perform the given request and ignore the result. Useful for "fire
        /// and forget" requests where failure is an okay option. The request is
        /// tied to the lifecycle of the ``Service`` performing the work and
        /// will be cancelled if the ``Service`` is deallocated.
        /// - Parameters:
        ///     - request: the request to be performed.
        public func perform<Method: _RequestMethod, Resource: _RequestResource, Body: _RequestBody, Parameters: _RequestParameters, Key: _ResponseNestedKey>(_ request: HTTP._Request<Method, Resource, Body, Parameters, Key>) async throws {
            try await base.performs(request)
        }

    }

    /// Provides a convenient way for performing requests which are side
    /// effects; that is, requests for which observing the response is
    /// unnecessary.
    var unobserved: SideEffectScope {
        return SideEffectScope(self)
    }

}

