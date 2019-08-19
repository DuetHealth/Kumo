import Foundation

public protocol RequestMethod { }
public protocol RequestResource { }
public protocol RequestBody { }
public protocol RequestParameters { }
public protocol ResponseNestedKey { }
public typealias RequestOption = RequestMethod & RequestResource & RequestBody & RequestParameters & ResponseNestedKey
public enum _NoOption: RequestOption { }
public enum _HasOption: RequestOption { }

fileprivate struct AnyEncodable: Encodable {

    let base: Encodable

    init(_ base: Encodable) {
        self.base = base
    }

    func encode(to encoder: Encoder) throws {
        try base.encode(to: encoder)
    }

}

fileprivate func mapBody<M1: RequestMethod, R1: RequestResource, P1: RequestParameters, B1: RequestBody, K1: ResponseNestedKey, M2: RequestMethod, R2: RequestResource, P2: RequestParameters, B2: RequestBody, K2: ResponseNestedKey>(from existing: HTTP._Request<M1, R1, P1, B1, K1>.BodyContainer) -> HTTP._Request<M2, R2, P2, B2, K2>.BodyContainer {
    switch existing {
    case .dynamic(let object): return HTTP._Request<M2, R2, P2, B2, K2>.BodyContainer.dynamic(object)
    case .typed(let encodable): return HTTP._Request<M2, R2, P2, B2, K2>.BodyContainer.typed(encodable)
    }
}

extension HTTP {
    public static let Request = _Request<_NoOption, _NoOption, _NoOption, _NoOption, _NoOption>.self

    enum ResourceLocator {
        case endpoint(String)
        case absoluteURL(URL)
    }

    public struct _Request<Method: RequestMethod, Resource: RequestResource, Parameters: RequestParameters, Body: RequestBody, Key: ResponseNestedKey> {

        // TODO: _HasOption could probably be expanded with protocols/types that define whether the body
        // needs encoded with a typed encoder or with a dynamic encoder (JSONSerialization).
        fileprivate enum BodyContainer {
            case typed(Encodable)
            case dynamic(Any)
        }

        var method: HTTP.Method
        var resourceLocator: HTTP.ResourceLocator
        var parameters: [String: Any]
        var nestingKey: String?
        private var body: BodyContainer?

        fileprivate init(method: HTTP.Method, resourceLocator: HTTP.ResourceLocator, parameters: [String: Any] = [:], body: BodyContainer? = nil, keyedUnder nestingKey: String? = nil) {
            self.method = method
            self.resourceLocator = resourceLocator
            self.parameters = parameters
            self.body = body
            self.nestingKey = nestingKey
        }

        func data(typedEncoder: RequestEncoding, dynamicEncoder: (Any) throws -> Data) throws -> Data? {
            switch body {
            case .some(.typed(let encodable)):
                return try typedEncoder.encode(AnyEncodable(encodable))
            case .some(.dynamic(let object)):
                return try dynamicEncoder(object)
            case .none:
                return .none
            }
        }

    }

}

public extension HTTP._Request where Method == _NoOption, Resource == _NoOption, Body == _NoOption, Parameters == _NoOption, Key == _NoOption {

    static func get(_ endpoint: String) -> HTTP._Request<_HasOption, _HasOption, _NoOption, _NoOption, _NoOption> {
        return HTTP._Request(method: .get, resourceLocator: .endpoint(endpoint))
    }

    static func get(_ url: URL) -> HTTP._Request<_HasOption, _HasOption, _NoOption, _NoOption, _NoOption> {
        return HTTP._Request(method: .get, resourceLocator: .absoluteURL(url))
    }

    static func post(_ endpoint: String) -> HTTP._Request<_HasOption, _HasOption, _NoOption, _NoOption, _NoOption> {
        return HTTP._Request(method: .post, resourceLocator: .endpoint(endpoint))
    }

    static func post(_ url: URL) -> HTTP._Request<_HasOption, _HasOption, _NoOption, _NoOption, _NoOption> {
        return HTTP._Request(method: .post, resourceLocator: .absoluteURL(url))
    }

    static func put(_ endpoint: String) -> HTTP._Request<_HasOption, _HasOption, _NoOption, _NoOption, _NoOption> {
        return HTTP._Request(method: .put, resourceLocator: .endpoint(endpoint))
    }

    static func put(_ url: URL) -> HTTP._Request<_HasOption, _HasOption, _NoOption, _NoOption, _NoOption> {
        return HTTP._Request(method: .put, resourceLocator: .absoluteURL(url))
    }

    static func delete(_ endpoint: String) -> HTTP._Request<_HasOption, _HasOption, _NoOption, _NoOption, _NoOption> {
        return HTTP._Request(method: .delete, resourceLocator: .endpoint(endpoint))
    }

    static func delete(_ url: URL) -> HTTP._Request<_HasOption, _HasOption, _NoOption, _NoOption, _NoOption> {
        return HTTP._Request(method: .delete, resourceLocator: .absoluteURL(url))
    }

    static func patch(_ endpoint: String) -> HTTP._Request<_HasOption, _HasOption, _NoOption, _NoOption, _NoOption> {
        return HTTP._Request(method: .patch, resourceLocator: .endpoint(endpoint))
    }

    static func patch(_ url: URL) -> HTTP._Request<_HasOption, _HasOption, _NoOption, _NoOption, _NoOption> {
        return HTTP._Request(method: .patch, resourceLocator: .absoluteURL(url))
    }


}


public extension HTTP._Request where Parameters == _NoOption {

    func parameters(_ parameters: [String: Any]) -> HTTP._Request<Method, Resource, _HasOption, Body, Key> {
        return HTTP._Request<Method, Resource, _HasOption, Body, Key>(method: method, resourceLocator: resourceLocator, parameters: parameters, body: body.map(mapBody(from:)), keyedUnder: nestingKey)
    }

}

public extension HTTP._Request where Body == _NoOption {

    func body(_ body: Encodable) -> HTTP._Request<Method, Resource, Parameters, _HasOption, Key> {
        return HTTP._Request<Method, Resource, Parameters, _HasOption, Key>(method: method, resourceLocator: resourceLocator, parameters: parameters, body: HTTP._Request<Method, Resource, Parameters, _HasOption, Key>.BodyContainer.typed(body), keyedUnder: nestingKey)
    }

    func body(_ body: Any) -> HTTP._Request<Method, Resource, Parameters, _HasOption, Key> {
        return HTTP._Request<Method, Resource, Parameters, _HasOption, Key>(method: method, resourceLocator: resourceLocator, parameters: parameters, body: HTTP._Request<Method, Resource, Parameters, _HasOption, Key>.BodyContainer.dynamic(body), keyedUnder: nestingKey)
    }

}

public extension HTTP._Request where Key == _NoOption {

    func keyed(under nestingKey: String) -> HTTP._Request<Method, Resource, Parameters, Body, _HasOption> {
        return HTTP._Request<Method, Resource, Parameters, Body, _HasOption>(method: method, resourceLocator: resourceLocator, parameters: parameters, body: body.map(mapBody(from:)), keyedUnder: nestingKey)
    }

}
