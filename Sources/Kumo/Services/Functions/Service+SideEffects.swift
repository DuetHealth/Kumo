import Foundation
import RxSwift

public extension Service {
    
    struct SideEffectScope {
        
        let base: Service
        
        init(_ base: Service) {
            self.base = base
        }

        @discardableResult public func perform<Method: RequestMethod, Resource: RequestResource, Body: RequestBody, Parameters: RequestParameters, Key: ResponseNestedKey>(_ request: HTTP._Request<Method, Resource, Body, Parameters, Key>) -> Disposable {
            return (base.perform(request) as Observable<Void>).subscribe()
        }

        @available(*, deprecated, message: "Use Service.perform instead.")
        @discardableResult func get(_ endpoint: String, parameters: [String: Any] = [:]) -> Disposable {
            let result: Observable<Void> = base.get(endpoint, parameters: parameters)
            return result
                .subscribe()
        }

        @available(*, deprecated, message: "Use Service.perform instead.")
        @discardableResult func post(_ endpoint: String, body: [String: Any]) -> Disposable {
            let result: Observable<Void> = base.post(endpoint, body: body)
            return result
                .subscribe()
        }

        @available(*, deprecated, message: "Use Service.perform instead.")
        @discardableResult func post<Body: Encodable>(_ endpoint: String, body: Body) -> Disposable {
            return (base.post(endpoint, body: body) as Observable<Void>)
                .subscribe()
        }

        @available(*, deprecated, message: "Use Service.perform instead.")
        @discardableResult func put<Body: Encodable>(_ endpoint: String, parameters: [String: Any] = [:], body: Body) -> Disposable {
            return (base.put(endpoint, parameters: parameters, body: body) as Observable<Void>)
                .subscribe()
        }

        @available(*, deprecated, message: "Use Service.perform instead.")
        @discardableResult func put(_ endpoint: String, parameters: [String: Any] = [:], body: [String: Any]) -> Disposable {
            let result: Observable<Void> = base.put(endpoint, body: body)
            return result
                .subscribe()
        }

        @available(*, deprecated, message: "Use Service.perform instead.")
        @discardableResult func delete(_ endpoint: String, parameters: [String: Any] = [:]) -> Disposable {
            let result: Observable<Void> = base.delete(endpoint, parameters: parameters)
            return result
                .subscribe()
        }
        
    }
    
    /// Provides a convenient way for performing requests which are side effects; that is, requests for which
    /// observing the response is unnecessary.
    var unobserved: SideEffectScope {
        return SideEffectScope(self)
    }
    
}
