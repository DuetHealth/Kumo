import Foundation

public protocol RequestMethod { }
public protocol RequestResource { }
public protocol RequestBody { }
public protocol RequestParameters { }
public protocol ResponseNestedKey { }
public typealias RequestOption = RequestMethod & RequestResource & RequestBody & RequestParameters & ResponseNestedKey
public enum _NoOption: RequestOption { }
public enum _HasOption: RequestOption { }

struct AnyEncodable: Encodable {

    let base: Encodable

    init(_ base: Encodable) {
        self.base = base
    }

    func encode(to encoder: Encoder) throws {
        try base.encode(to: encoder)
    }

}

extension HTTP {
    public static let Request = _Request<_NoOption, _NoOption, _NoOption, _NoOption, _NoOption>.self

    // TODO: _HasOption could probably be expanded with protocols/types that define whether the body
    // needs encoded with a typed encoder or with a dynamic encoder (JSONSerialization).
    fileprivate enum BodyContainer {
        case typed(Encodable)
        case dynamic(Any)
        case multipart(MultipartForm)
    }

    struct Content {
        let data: Data
        let mimeType: MIMEType

        init(data: Data, mimeType: MIMEType) {
            self.data = data
            self.mimeType = mimeType
        }
    }

    enum ResourceLocator {
        case relative(String)
        case absolute(URL)
    }

    public struct _Request<Method: RequestMethod, Resource: RequestResource, Parameters: RequestParameters, Body: RequestBody, Key: ResponseNestedKey> {

        var method: HTTP.Method
        var resourceLocator: HTTP.ResourceLocator
        var parameters: [String: Any]
        var nestingKey: String?
        private var body: HTTP.BodyContainer?

        fileprivate init(method: HTTP.Method, resourceLocator: HTTP.ResourceLocator, parameters: [String: Any] = [:], body: BodyContainer? = nil, keyedUnder nestingKey: String? = nil) {
            self.method = method
            self.resourceLocator = resourceLocator
            self.parameters = parameters
            self.body = body
            self.nestingKey = nestingKey
        }

        func data(typedEncoder: RequestEncoding, dynamicEncoder: (Any) throws -> Data) throws -> Content? {
            switch body {
            case .some(.typed(let encodable)):
                let data = try typedEncoder.encode(AnyEncodable(encodable))
                return Content(data: data, mimeType: typedEncoder.contentType)
            case .some(.dynamic(let object)):
                let data = try dynamicEncoder(object)
                return Content(data: data, mimeType: typedEncoder.contentType)
            case .some(.multipart(let object)):
                let data = object.data
                return Content(data: data, mimeType: MIMEType.multipartFormData(boundary: object.boundary))
            case .none:
                return .none
            }
        }

    }

    public struct _DownloadRequest<Resource: RequestResource, Parameters: RequestParameters> {

        var baseRepresentation: HTTP._Request<_HasOption, Resource, Parameters, _NoOption, _NoOption> {
            return HTTP._Request(method: .get, resourceLocator: resourceLocator, parameters: parameters)
        }

        var resourceLocator: HTTP.ResourceLocator
        var parameters: [String: Any]

        fileprivate init(resourceLocator: HTTP.ResourceLocator, parameters: [String: Any] = [:]) {
            self.resourceLocator = resourceLocator
            self.parameters = parameters
        }

    }

    public struct _UploadRequest<Resource: RequestResource, Parameters: RequestParameters, Body: RequestBody> {

    }

}

public extension HTTP._Request where Method == _NoOption, Resource == _NoOption, Body == _NoOption, Parameters == _NoOption, Key == _NoOption {

    static func get(_ endpoint: String) -> HTTP._Request<_HasOption, _HasOption, _NoOption, _NoOption, _NoOption> {
        return HTTP._Request(method: .get, resourceLocator: .relative(endpoint))
    }

    static func get(_ url: URL) -> HTTP._Request<_HasOption, _HasOption, _NoOption, _NoOption, _NoOption> {
        return HTTP._Request(method: .get, resourceLocator: .absolute(url))
    }

    static func post(_ endpoint: String) -> HTTP._Request<_HasOption, _HasOption, _NoOption, _NoOption, _NoOption> {
        return HTTP._Request(method: .post, resourceLocator: .relative(endpoint))
    }

    static func post(_ url: URL) -> HTTP._Request<_HasOption, _HasOption, _NoOption, _NoOption, _NoOption> {
        return HTTP._Request(method: .post, resourceLocator: .absolute(url))
    }

    static func put(_ endpoint: String) -> HTTP._Request<_HasOption, _HasOption, _NoOption, _NoOption, _NoOption> {
        return HTTP._Request(method: .put, resourceLocator: .relative(endpoint))
    }

    static func put(_ url: URL) -> HTTP._Request<_HasOption, _HasOption, _NoOption, _NoOption, _NoOption> {
        return HTTP._Request(method: .put, resourceLocator: .absolute(url))
    }

    static func delete(_ endpoint: String) -> HTTP._Request<_HasOption, _HasOption, _NoOption, _NoOption, _NoOption> {
        return HTTP._Request(method: .delete, resourceLocator: .relative(endpoint))
    }

    static func delete(_ url: URL) -> HTTP._Request<_HasOption, _HasOption, _NoOption, _NoOption, _NoOption> {
        return HTTP._Request(method: .delete, resourceLocator: .absolute(url))
    }

    static func patch(_ endpoint: String) -> HTTP._Request<_HasOption, _HasOption, _NoOption, _NoOption, _NoOption> {
        return HTTP._Request(method: .patch, resourceLocator: .relative(endpoint))
    }

    static func patch(_ url: URL) -> HTTP._Request<_HasOption, _HasOption, _NoOption, _NoOption, _NoOption> {
        return HTTP._Request(method: .patch, resourceLocator: .absolute(url))
    }

    static func download(_ url: URL) -> HTTP._DownloadRequest<_HasOption, _NoOption> {
        return HTTP._DownloadRequest(resourceLocator: .absolute(url))
    }

    static func download(_ endpoint: String) -> HTTP._DownloadRequest<_HasOption, _NoOption> {
        return HTTP._DownloadRequest(resourceLocator: .relative(endpoint))
    }

}


public extension HTTP._Request where Parameters == _NoOption {

    func parameters(_ parameters: [String: Any]) -> HTTP._Request<Method, Resource, _HasOption, Body, Key> {
        return HTTP._Request<Method, Resource, _HasOption, Body, Key>(method: method, resourceLocator: resourceLocator, parameters: parameters, body: body, keyedUnder: nestingKey)
    }

}

public extension HTTP._Request where Body == _NoOption {

    func body(_ body: Encodable) -> HTTP._Request<Method, Resource, Parameters, _HasOption, Key> {
        return HTTP._Request<Method, Resource, Parameters, _HasOption, Key>(method: method, resourceLocator: resourceLocator, parameters: parameters, body: .typed(body), keyedUnder: nestingKey)
    }

    func body(_ body: Any) -> HTTP._Request<Method, Resource, Parameters, _HasOption, Key> {
        return HTTP._Request<Method, Resource, Parameters, _HasOption, Key>(method: method, resourceLocator: resourceLocator, parameters: parameters, body: .dynamic(body), keyedUnder: nestingKey)
    }

    func body(_ multipartBody: MultipartForm) -> HTTP._Request<Method, Resource, Parameters, _HasOption, Key> {
        return HTTP._Request<Method, Resource, Parameters, _HasOption, Key>(method: method, resourceLocator: resourceLocator, parameters: parameters, body: .multipart(multipartBody), keyedUnder: nestingKey)
    }

}

public extension HTTP._Request where Key == _NoOption {

    func keyed(under nestingKey: String) -> HTTP._Request<Method, Resource, Parameters, Body, _HasOption> {
        return HTTP._Request<Method, Resource, Parameters, Body, _HasOption>(method: method, resourceLocator: resourceLocator, parameters: parameters, body: body, keyedUnder: nestingKey)
    }

}

public extension HTTP._DownloadRequest where Parameters == _NoOption {

    func parameter(_ key: String, _ value: Any) -> HTTP._DownloadRequest<Resource, _HasOption> {
        return HTTP._DownloadRequest(resourceLocator: resourceLocator, parameters: [key: value])
    }

    func parameters(_ parameters: [String: Any]) -> HTTP._DownloadRequest<Resource, _HasOption> {
        return HTTP._DownloadRequest(resourceLocator: resourceLocator, parameters: parameters)
    }

}
