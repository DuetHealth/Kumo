import Foundation

#if canImport(KumoCoding)
import KumoCoding
#endif

public protocol _RequestMethod { }
public protocol _RequestResource { }
public protocol _RequestBody { }
public protocol _RequestParameters { }
public protocol _ResponseNestedKey { }
public protocol _RequestDispositionName { }
public protocol _UploadProgress { }
public typealias _RequestOption = _RequestMethod & _RequestResource & _RequestBody & _RequestParameters & _ResponseNestedKey & _RequestDispositionName & _UploadProgress
public enum _NoOption: _RequestOption { }
public enum _HasOption: _RequestOption { }

extension HTTP {
    public typealias Request = _Request<_NoOption, _NoOption, _NoOption, _NoOption, _NoOption>

    // TODO: _HasOption could probably be expanded with protocols / types that
    // define whether the body needs encoded with a typed encoder or with a
    // dynamic encoder (JSONSerialization).
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

    public struct _Request<Method: _RequestMethod, Resource: _RequestResource, Parameters: _RequestParameters, Body: _RequestBody, Key: _ResponseNestedKey> {

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

    public struct _DownloadRequest<Resource: _RequestResource, Parameters: _RequestParameters> {

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

    public struct _UploadRequest<Resource: _RequestResource, Parameters: _RequestParameters, Body: _RequestBody, Name: _RequestDispositionName, Progress: _UploadProgress> {

        var baseRepresentation: HTTP._Request<_HasOption, Resource, Parameters, _NoOption, _NoOption> {
            return HTTP._Request(method: .post, resourceLocator: resourceLocator, parameters: parameters)
        }

        var resourceLocator: HTTP.ResourceLocator
        var parameters: [String: Any]
        var file: URL?
        var key: String?

        fileprivate init(resourceLocator: HTTP.ResourceLocator, parameters: [String: Any] = [:], file: URL? = nil, keyedUnder key: String? = nil) {
            self.resourceLocator = resourceLocator
            self.parameters = parameters
            self.file = file
            self.key = key
        }

    }

}

// MARK: Base Requests

public extension HTTP._Request where Method == _NoOption, Resource == _NoOption, Body == _NoOption, Parameters == _NoOption, Key == _NoOption {

    /// A GET request to the path extension corresponding to the provided
    /// `endpoint`.
    static func get(_ endpoint: String) -> HTTP._Request<_HasOption, _HasOption, _NoOption, _NoOption, _NoOption> {
        return HTTP._Request(method: .get, resourceLocator: .relative(endpoint))
    }

    /// A GET request to the provided absolute `url`.
    static func get(_ url: URL) -> HTTP._Request<_HasOption, _HasOption, _NoOption, _NoOption, _NoOption> {
        return HTTP._Request(method: .get, resourceLocator: .absolute(url))
    }

    /// A POST request to the path extension corresponding to the provided
    /// `endpoint`.
    static func post(_ endpoint: String) -> HTTP._Request<_HasOption, _HasOption, _NoOption, _NoOption, _NoOption> {
        return HTTP._Request(method: .post, resourceLocator: .relative(endpoint))
    }

    /// A POST request to the provided absolute `url`.
    static func post(_ url: URL) -> HTTP._Request<_HasOption, _HasOption, _NoOption, _NoOption, _NoOption> {
        return HTTP._Request(method: .post, resourceLocator: .absolute(url))
    }

    /// A PUT request to the path extension corresponding to the provided
    /// `endpoint`.
    static func put(_ endpoint: String) -> HTTP._Request<_HasOption, _HasOption, _NoOption, _NoOption, _NoOption> {
        return HTTP._Request(method: .put, resourceLocator: .relative(endpoint))
    }

    /// A PUT request to the provided absolute `url`.
    static func put(_ url: URL) -> HTTP._Request<_HasOption, _HasOption, _NoOption, _NoOption, _NoOption> {
        return HTTP._Request(method: .put, resourceLocator: .absolute(url))
    }

    /// A DELETE request to the path extension corresponding to the provided
    /// `endpoint`.
    static func delete(_ endpoint: String) -> HTTP._Request<_HasOption, _HasOption, _NoOption, _NoOption, _NoOption> {
        return HTTP._Request(method: .delete, resourceLocator: .relative(endpoint))
    }

    /// A DELETE request to the provided absolute `url`.
    static func delete(_ url: URL) -> HTTP._Request<_HasOption, _HasOption, _NoOption, _NoOption, _NoOption> {
        return HTTP._Request(method: .delete, resourceLocator: .absolute(url))
    }

    /// A PATCH request to the path extension corresponding to the provided
    /// `endpoint`.
    static func patch(_ endpoint: String) -> HTTP._Request<_HasOption, _HasOption, _NoOption, _NoOption, _NoOption> {
        return HTTP._Request(method: .patch, resourceLocator: .relative(endpoint))
    }

    /// A PATCH request to the provided absolute `url`.
    static func patch(_ url: URL) -> HTTP._Request<_HasOption, _HasOption, _NoOption, _NoOption, _NoOption> {
        return HTTP._Request(method: .patch, resourceLocator: .absolute(url))
    }

    /// A download request to the path extension corresponding to the provided
    /// `endpoint`.
    static func download(_ endpoint: String) -> HTTP._DownloadRequest<_HasOption, _NoOption> {
        return HTTP._DownloadRequest(resourceLocator: .relative(endpoint))
    }

    /// A download request to the provided absolute `url`.
    static func download(_ url: URL) -> HTTP._DownloadRequest<_HasOption, _NoOption> {
        return HTTP._DownloadRequest(resourceLocator: .absolute(url))
    }

    /// An upload request to the path extension corresponding to the provided
    /// `endpoint`.
    static func upload(_ endpoint: String) -> HTTP._UploadRequest<_HasOption, _NoOption, _NoOption, _NoOption, _NoOption> {
        return HTTP._UploadRequest(resourceLocator: .relative(endpoint))
    }

    /// An upload request to the provided absolute `url`.
    static func upload(_ url: URL) -> HTTP._UploadRequest<_HasOption, _NoOption, _NoOption, _NoOption, _NoOption> {
        return HTTP._UploadRequest(resourceLocator: .absolute(url))
    }

}

// MARK: Request Options

public extension HTTP._Request where Parameters == _NoOption {

    /// Sets the URL query parameters for the request.
    /// - Parameters:
    ///   - key: The key for the query parameter.
    ///   - value: The value for the query parameter.
    /// - Returns: A modified request with the provided `key` and `value`
    /// parameter to be used in the URL query.
    func parameter(_ key: String, _ value: Any) -> HTTP._Request<Method, Resource, _HasOption, Body, Key> {
        return HTTP._Request<Method, Resource, _HasOption, Body, Key>(method: method, resourceLocator: resourceLocator, parameters: [key: value], body: body, keyedUnder: nestingKey)
    }

    /// Sets the URL query parameters for the request.
    /// - Parameter parameters: A dictionary of parameters to be used in the
    /// request URL query.
    /// - Returns: A modified request that's URL will include the given
    /// `parameters`.
    func parameters(_ parameters: [String: Any]) -> HTTP._Request<Method, Resource, _HasOption, Body, Key> {
        return HTTP._Request<Method, Resource, _HasOption, Body, Key>(method: method, resourceLocator: resourceLocator, parameters: parameters, body: body, keyedUnder: nestingKey)
    }

}

public extension HTTP._Request where Body == _NoOption {


    /// Sets the body for the request.
    /// - Parameter body: An encodable body object.
    /// - Returns: A modified request with the provided encodable body.
    func body(_ body: Encodable) -> HTTP._Request<Method, Resource, Parameters, _HasOption, Key> {
        return HTTP._Request<Method, Resource, Parameters, _HasOption, Key>(method: method, resourceLocator: resourceLocator, parameters: parameters, body: .typed(body), keyedUnder: nestingKey)
    }

    /// Sets the body for the request.
    /// - Parameter body: A body object.
    /// - Returns: A modified request with the provided body.
    func body(_ body: Any) -> HTTP._Request<Method, Resource, Parameters, _HasOption, Key> {
        return HTTP._Request<Method, Resource, Parameters, _HasOption, Key>(method: method, resourceLocator: resourceLocator, parameters: parameters, body: .dynamic(body), keyedUnder: nestingKey)
    }

    /// Sets the body for the request.
    /// - Parameter body: A body object.
    /// - Returns: A modified request with the provided multipart form body.
    func body(_ multipartBody: MultipartForm) -> HTTP._Request<Method, Resource, Parameters, _HasOption, Key> {
        return HTTP._Request<Method, Resource, Parameters, _HasOption, Key>(method: method, resourceLocator: resourceLocator, parameters: parameters, body: .multipart(multipartBody), keyedUnder: nestingKey)
    }

}

public extension HTTP._Request where Key == _NoOption {

    /// Sets the key under which to look for the response of the request.
    /// - Parameter key: A key that exists under the decoded response.
    /// - Returns: A modified request that returns a result keyed in the
    /// response under `nestingKey`.
    func keyed(under nestingKey: String) -> HTTP._Request<Method, Resource, Parameters, Body, _HasOption> {
        return HTTP._Request<Method, Resource, Parameters, Body, _HasOption>(method: method, resourceLocator: resourceLocator, parameters: parameters, body: body, keyedUnder: nestingKey)
    }

}

public extension HTTP._DownloadRequest where Parameters == _NoOption {

    /// Sets the URL query parameters for the request.
    /// - Parameters:
    ///   - key: The key for the query parameter.
    ///   - value: The value for the query parameter.
    /// - Returns: A modified request with the provided `key` and `value`
    /// parameter to be used in the URL query.
    func parameter(_ key: String, _ value: Any) -> HTTP._DownloadRequest<Resource, _HasOption> {
        return HTTP._DownloadRequest(resourceLocator: resourceLocator, parameters: [key: value])
    }

    /// Sets the URL query parameters for the request.
    /// - Parameter parameters: A dictionary of parameters to be used in the
    /// request URL query.
    /// - Returns: A modified request that's URL will include the given
    /// `parameters`.
    func parameters(_ parameters: [String: Any]) -> HTTP._DownloadRequest<Resource, _HasOption> {
        return HTTP._DownloadRequest(resourceLocator: resourceLocator, parameters: parameters)
    }

}

public extension HTTP._UploadRequest where Parameters == _NoOption {

    /// Sets the URL query parameters for the request.
    /// - Parameters:
    ///   - key: The key for the query parameter.
    ///   - value: The value for the query parameter.
    /// - Returns: A modified request with the provided `key` and `value`
    /// parameter to be used in the URL query.
    func parameter(_ key: String, _ value: Any) -> HTTP._UploadRequest<Resource, _HasOption, Body, Name, Progress> {
        return .init(resourceLocator: resourceLocator, parameters: [key: value], file: file, keyedUnder: key)
    }

    /// Sets the URL query parameters for the request.
    /// - Parameter parameters: A dictionary of parameters to be used in the
    /// request URL query.
    /// - Returns: A modified request that's URL will include the given
    /// `parameters`.
    func parameters(_ parameters: [String: Any]) -> HTTP._UploadRequest<Resource, _HasOption, Body, Name, Progress> {
        return .init(resourceLocator: resourceLocator, parameters: parameters, file: file, keyedUnder: key)
    }

}

public extension HTTP._UploadRequest where Body == _NoOption {

    /// Sets the file to be used for the data of the upload request.
    /// - Parameter file: A file `URL`.
    /// - Returns: A modified upload request that uploads the data from the
    /// specified `file`.
    func file(_ file: URL) -> HTTP._UploadRequest<Resource, Parameters, _HasOption, Name, Progress> {
        return .init(resourceLocator: resourceLocator, parameters: parameters, file: file, keyedUnder: key)
    }

}

public extension HTTP._UploadRequest where Name == _NoOption {

    /// Sets the name to use for the file upload disposition name.
    /// - Parameter key: The disposition name.
    /// - Returns: A modified upload request that keys the file underneath the specified
    /// disposition `key`.
    func keyed(under key: String) -> HTTP._UploadRequest<Resource, Parameters, Body, _HasOption, Progress> {
        return .init(resourceLocator: resourceLocator, parameters: parameters, file: file, keyedUnder: key)
    }

}

public extension HTTP._UploadRequest where Progress == _NoOption {

    /// An upload request that publishes the progress of the upload.
    func progress() -> HTTP._UploadRequest<Resource, Parameters, Body, Name, _HasOption> {
        return .init(resourceLocator: resourceLocator, parameters: parameters, file: file, keyedUnder: key)
    }

}
