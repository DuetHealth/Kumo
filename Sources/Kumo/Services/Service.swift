import Combine
import Foundation

#if canImport(KumoCoding)
    import KumoCoding
#endif

public struct ServiceKey: Hashable {
    let stringValue: String

    public init(_ name: String) {
        stringValue = name
    }
}

public struct ResponseObjectError: Error {
    public let responseObject: URLResponse?
    public let wrappedError: Error

    init(error: Error, responseObject: URLResponse?) {
        self.responseObject = responseObject
        wrappedError = error
    }

    public var localizedDescription: String {
        return wrappedError.localizedDescription
    }
}

public class Service {
    /// The base URL for all requests. The URLs for requests performed by the service are made
    /// by appending path components to this URL.
    public let baseURL: URL?

    private let delegate = URLSessionInvalidationDelegate()

    /// The type of error returned by the server. When a response returns an error status code,
    /// the service will attempt to decode the body of the response as this type.
    ///
    /// The default value of this is `nil`. If no type is set, the service will not attempt to
    /// decode an error body.
    public var errorType = ResponseError?.none

    /// THe object which encodes request bodies which conform to the `Encodable` protocol.
    ///
    /// The default instance is a `JSONEncoder`.
    public var requestEncoder: RequestEncoding = JSONEncoder()

    /// THe object which decodes response bodies which conform to the `Decodable` protocol.
    ///
    /// The default instance is a `JSONDecoder`.
    public var requestDecoder: RequestDecoding = JSONDecoder()

    /// The behavior to use for encoding dynamically-typed request bodies.
    ///
    /// The default implementation uses Foundation's `JSONSerialization`.
    public var dynamicRequestEncodingStrategy: (Any) throws -> Data

    /// The behavior to use for decoding dynamically-typed response bodies.
    ///
    /// The default implementation uses Foundation's `JSONSerialization`.
    public var dynamicRequestDecodingStrategy: (Data) throws -> Any

    /// The scheduler on which to publish tasks.
    ///
    /// By default, tasks are published on the main thread.
    public var receivingScheduler = DispatchQueue.main

    /// The scheduler on which to perform work such as decoding data.
    ///
    /// By default, work is done on `DispatchQueue.global()`.
    public var subscriptionScheduler = DispatchQueue.global()

    /// The characters to be allowed in the query sectiom of request URLs.
    public var urlQueryAllowedCharacters = CharacterSet.urlQueryAllowed

    private(set) var session: URLSession

    /// Returns the headers applied to all requests.
    public var commonHTTPHeaders: [HTTP.Header: Any]? {
        return session.configuration.httpHeaders
    }

    public init(baseURL: URL?, runsInBackground: Bool = false, configuration: ((URLSessionConfiguration) -> Void)? = nil) {
        self.baseURL = baseURL
        let sessionConfiguration = runsInBackground ? URLSessionConfiguration.background(withIdentifier: baseURL?.absoluteString ?? UUID().uuidString) : .default
        configuration?(sessionConfiguration)
        session = URLSession(configuration: sessionConfiguration, delegate: delegate, delegateQueue: nil)
        dynamicRequestEncodingStrategy = { object in
            try JSONSerialization.data(withJSONObject: object, options: [])
        }
        dynamicRequestDecodingStrategy = { data in
            try JSONSerialization.jsonObject(with: data, options: [])
        }
    }

    internal func copySettings(from _: ApplicationLayer) {}

    /// Provides a way to reconfigure the URLSessionConfiguration that powers the Service.
    public func reconfigure(applying changes: @escaping (URLSessionConfiguration) -> Void) {
        session.finishTasksAndInvalidate { [unowned self] session, _ in
            let newConfiguration: URLSessionConfiguration = session.configuration.copy()
            changes(newConfiguration)
            self.session = URLSession(configuration: newConfiguration, delegate: self.delegate, delegateQueue: nil)
        }
    }

    /// Provides a way to asynchronously reconfigure the URLSessionConfiguration that powers the Service.
    /// Prefer this over `reconfigure(applying:_)` when making a request that will modify the session
    /// configuration based on the result of the request, e.g.: upon logging in and receiving a token that will be
    /// added to subsequent headers.
    public func reconfiguring(applying changes: @escaping (URLSessionConfiguration) -> Void) -> AnyPublisher<Void, Never> {
        Future<Void, Never> { [weak self] promise in
            guard let self = self else {
                promise(.success(()))
                return
            }
            self.session.finishTasksAndInvalidate { [unowned self] session, _ in
                let newConfiguration: URLSessionConfiguration = session.configuration.copy()
                changes(newConfiguration)
                self.session = URLSession(configuration: newConfiguration, delegate: self.delegate, delegateQueue: nil)
                promise(.success(()))
            }
        }
        .receive(on: receivingScheduler)
        .eraseToAnyPublisher()
    }

    public func upload<Response: Decodable>(_ endpoint: String, file: URL, under key: String) -> AnyPublisher<Response, Error> {
        Deferred<AnyPublisher<Response, Error>> {
            Future<Response, Error> { [self] promise in
                do {
                    var request = try self.createRequest(method: .post, endpoint: endpoint)
                    guard file.isFileURL else { throw UploadError.notAFileURL(file) }
                    let form = try MultipartForm(file: file, under: key, encoding: .utf8)
                    request.set(contentType: .multipartFormData(boundary: form.boundary))
                    let task = self.session.uploadTask(with: request, from: form.data) {
                        let decoded: Result<Response, Error> = self.result(data: $0, response: $1, error: $2)
                        self.fulfill(promise: promise, for: decoded)
                    }
                    task.resume()
                } catch {
                    promise(.failure(error))
                }
            }
            .eraseToAnyPublisher()
        }
        .subscribe(on: subscriptionScheduler)
        .receive(on: receivingScheduler)
        .eraseToAnyPublisher()
    }

    func createRequest(method: HTTP.Method, endpoint: String, queryParameters: [String: Any] = [:], body: [String: Any]? = nil) throws -> URLRequest {
        let data: Data?
        do { data = try body.map(dynamicRequestEncodingStrategy) }
        catch { throw HTTPError.unserializableRequestBody(object: body, originalError: error) }
        return try createRequest(method: method, endpoint: endpoint, queryParameters: queryParameters, body: data)
    }

    func createRequest<Body: Encodable>(method: HTTP.Method, endpoint: String, queryParameters: [String: Any] = [:], body: Body? = nil) throws -> URLRequest {
        let data: Data?
        do { data = try body.map(requestEncoder.encode) }
        catch { throw HTTPError.unserializableRequestBody(object: body, originalError: error) }
        return try createRequest(method: method, endpoint: endpoint, queryParameters: queryParameters, body: data)
    }

    func createRequest(method: HTTP.Method, endpoint: String, queryParameters: [String: Any], body: Data?) throws -> URLRequest {
        guard let baseURL = self.url(given: endpoint) else {
            throw HTTPError.malformedURLString(endpoint, parameters: queryParameters)
        }

        let url = endpoint.isEmpty ? baseURL : baseURL.appendingPathComponent(endpoint)
        let finalURL: URL
        if queryParameters.isEmpty { finalURL = url }
        else {
            guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                throw HTTPError.malformedURL(url, parameters: queryParameters)
            }
            components.percentEncodedQuery = queryParameters.compactMap {
                guard let key = $0.key.addingPercentEncoding(withAllowedCharacters: urlQueryAllowedCharacters) else {
                    return nil
                }

                if let value = ($0.value as? String)?.addingPercentEncoding(withAllowedCharacters: urlQueryAllowedCharacters) {
                    return "\(key)=\(value)"
                }

                return "\(key)=\($0.value)"
            }.joined(separator: "&")
            guard components.url != nil else {
                throw HTTPError.malformedURL(url, parameters: queryParameters)
            }
            finalURL = components.url!
        }
        var request = URLRequest(url: finalURL)
        request.httpHeaders = [.contentType: requestEncoder.contentType.rawValue,
                               .accept: requestDecoder.acceptType.rawValue]
        request.httpMethod = method.rawValue
        request.httpBody = body
        return request
    }

    /// Converts the results of a `URLSessionDataTask` into a `Result` with which consumers may
    /// perform side effects.
    func result(data: Data?, response: URLResponse?, error: Error?) -> Result<Void, Error> {
        if let error = error { return .failure(ResponseObjectError(error: error, responseObject: response)) }
        guard let httpResponse = response as? HTTPURLResponse else {
            return .failure(ResponseObjectError(error: response == nil ? HTTPError.emptyResponse : HTTPError.unsupportedResponse, responseObject: response))
        }
        if httpResponse.status.isError {
            return errorType.flatMap { type in
                data.map {
                    do { return try .failure(ResponseObjectError(error: type.decode(data: $0, with: requestDecoder), responseObject: response)) }
                    catch { return .failure(ResponseObjectError(error: HTTPError.corruptedError(type.type, decodingError: error), responseObject: response)) }
                } ?? .failure(ResponseObjectError(error: HTTPError.ambiguousError(httpResponse.status), responseObject: response))
            } ?? .failure(ResponseObjectError(error: HTTPError.ambiguousError(httpResponse.status), responseObject: response))
        }
        return .success(())
    }

    /// Converts the results of a `URLSessionDataTask` into a `Result` with which consumers may
    /// act on an element.
    private func result<Response: Decodable>(data: Data?, response: URLResponse?, error: Error?) -> Result<Response, Error> {
        if let error = error {
            return .failure(ResponseObjectError(error: error, responseObject: response))
        }
        guard let httpResponse = response as? HTTPURLResponse else {
            return .failure(ResponseObjectError(error: response == nil ? HTTPError.emptyResponse : HTTPError.unsupportedResponse, responseObject: response))
        }
        if httpResponse.status.isError {
            return errorType.flatMap { type in
                data.map {
                    do { return try .failure(ResponseObjectError(error: type.decode(data: $0, with: requestDecoder), responseObject: response)) }
                    catch { return .failure(ResponseObjectError(error: HTTPError.corruptedError(type.type, decodingError: error), responseObject: response)) }
                } ?? .failure(ResponseObjectError(error: HTTPError.ambiguousError(httpResponse.status), responseObject: response))
            } ?? .failure(ResponseObjectError(error: HTTPError.ambiguousError(httpResponse.status), responseObject: response))
        }
        return data.map {
            do { return try .success(self.requestDecoder.decode(Response.self, from: $0)) }
            catch { return .failure(ResponseObjectError(error: error, responseObject: response)) }
        } ?? .failure(ResponseObjectError(error: HTTPError.ambiguousError(httpResponse.status), responseObject: response))
    }

    /// Converts the results of a `URLSessionDataTask` into a `Result` with which consumers may
    /// act on an element.
    func result(data: Data?, response: URLResponse?, error: Error?) -> Result<Any, Error> {
        if let error = error {
            return .failure(ResponseObjectError(error: error, responseObject: response))
        }
        guard let httpResponse = response as? HTTPURLResponse else {
            return .failure(ResponseObjectError(error: response == nil ? HTTPError.emptyResponse : HTTPError.unsupportedResponse, responseObject: response))
        }
        if httpResponse.status.isError {
            return errorType.flatMap { type in
                data.map {
                    do { return try .failure(ResponseObjectError(error: type.decode(data: $0, with: requestDecoder), responseObject: response)) }
                    catch { return .failure(ResponseObjectError(error: HTTPError.corruptedError(type.type, decodingError: error), responseObject: response)) }
                } ?? .failure(ResponseObjectError(error: HTTPError.ambiguousError(httpResponse.status), responseObject: response))
            } ?? .failure(ResponseObjectError(error: HTTPError.ambiguousError(httpResponse.status), responseObject: response))
        }
        return data.map {
            do { return try .success(self.dynamicRequestDecodingStrategy($0)) }
            catch { return .failure(ResponseObjectError(error: error, responseObject: response)) }
        } ?? .failure(ResponseObjectError(error: HTTPError.ambiguousError(httpResponse.status), responseObject: response))
    }

    /// Converts the results of a `URLSessionDownloadTask` into a `Result` with which consumer
    /// may act on an element.
    func downloadResultToURL(url: URL?, response: URLResponse?, error: Error?) -> Result<URL, Error> {
        if let error = error { return .failure(error) }
        guard let httpResponse = response as? HTTPURLResponse else {
            return .failure(response == nil ? HTTPError.emptyResponse : HTTPError.unsupportedResponse)
        }
        if httpResponse.status.isError {
            return .failure(HTTPError.ambiguousError(httpResponse.status))
        }
        // TODO: in the previous implementation a nil URL would immediately complete. Was that
        // truly the desired behavior?
        guard let url = url else { return .failure(HTTPError.ambiguousError(httpResponse.status)) }
        let fileName = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
        let fileType = (response?.mimeType).flatMap { try? FileType(mimeType: $0) }
        let newURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName, isDirectory: false)
            .appendingPathExtension(fileType?.fileExtension ?? "")
        do {
            try FileManager.default.moveItem(atPath: url.path, toPath: newURL.path)
            return .success(newURL)
        } catch {
            return .failure(error)
        }
    }

    private func url(given endpoint: String) -> URL? {
        if let url = self.baseURL {
            return url
        }
        return URL(string: endpoint)
    }
}

public extension Service {
    func fulfill<T>(promise: Future<T, Error>.Promise, for result: Result<T, Error>) {
        switch result {
        case let .failure(error): promise(.failure(error))
        case let .success(value): promise(.success(value))
        }
    }

    func perform<Response: Decodable, Method: RequestMethod, Resource: RequestResource, Parameters: RequestParameters, Body: RequestBody, Key: ResponseNestedKey>(_ request: HTTP._Request<Method, Resource, Parameters, Body, Key>) -> AnyPublisher<Response, Error> {
        Deferred<AnyPublisher<Response, Error>> {
            Future<Response, Error> { promise in
                let urlRequest: URLRequest
                do {
                    urlRequest = try self.createURLRequest(from: request)
                } catch {
                    promise(.failure(error))
                    return
                }

                let task = self.session.dataTask(with: urlRequest) { (data: Data?, response: URLResponse?, error: Error?) in
                    if let key = request.nestingKey {
                        let result: Result<JSONWrapper<Response>, Error> = self.result(data: data, response: response, error: error)
                        switch result {
                        case let .failure(error):
                            promise(.failure(error))
                        case let .success(wrapper):
                            do {
                                try promise(.success(wrapper.value(forKey: key)))
                            } catch {
                                promise(.failure(error))
                            }
                        }
                    } else {
                        let result: Result<Response, Error> = self.result(data: data, response: response, error: error)
                        self.fulfill(promise: promise, for: result)
                    }
                }
                task.resume()
            }

            .eraseToAnyPublisher()
        }
        .subscribe(on: subscriptionScheduler)
        .receive(on: receivingScheduler)
        .eraseToAnyPublisher()
    }

    func perform<Method: RequestMethod, Resource: RequestResource, Parameters: RequestParameters, Body: RequestBody, Key: ResponseNestedKey>(_ request: HTTP._Request<Method, Resource, Parameters, Body, Key>) -> AnyPublisher<Void, Error> {
        Deferred<AnyPublisher<Void, Error>> {
            Future<Void, Error> { promise in
                do {
                    let urlRequest = try self.createURLRequest(from: request)
                    let task = self.session.dataTask(with: urlRequest) { (data: Data?, response: URLResponse?, error: Error?) in
                        let result: Result<Void, Error> = self.result(data: data, response: response, error: error)
                        self.fulfill(promise: promise, for: result)
                    }
                    task.resume()
                } catch {
                    promise(.failure(error))
                }
            }
            .eraseToAnyPublisher()
        }
        .subscribe(on: subscriptionScheduler)
        .receive(on: receivingScheduler)
        .eraseToAnyPublisher()
    }

    func perform<Method: RequestMethod, Resource: RequestResource, Parameters: RequestParameters, Body: RequestBody, Key: ResponseNestedKey>(_ request: HTTP._Request<Method, Resource, Parameters, Body, Key>) -> AnyPublisher<Any, Error> {
        Deferred<AnyPublisher<Any, Error>> {
            Future<Any, Error> { promise in
                do {
                    let urlRequest = try self.createURLRequest(from: request)
                    let task = self.session.dataTask(with: urlRequest) { (data: Data?, response: URLResponse?, error: Error?) in
                        let result: Result<Any, Error> = self.result(data: data, response: response, error: error)
                        self.fulfill(promise: promise, for: result)
                    }
                    task.resume()
                } catch {
                    promise(.failure(error))
                }
            }
            .eraseToAnyPublisher()
        }
        .subscribe(on: subscriptionScheduler)
        .receive(on: receivingScheduler)
        .eraseToAnyPublisher()
    }

    func perform<Resource: RequestResource, Parameters: RequestParameters>(_ request: HTTP._DownloadRequest<Resource, Parameters>) -> AnyPublisher<URL, Error> {
        Deferred<AnyPublisher<URL, Error>> {
            Future<URL, Error> { promise in
                do {
                    var urlRequest = try self.createURLRequest(from: request.baseRepresentation)
                    urlRequest.remove(header: .accept)
                    let task = self.session.downloadTask(with: urlRequest) {
                        let result: Result<URL, Error> = self.downloadResultToURL(url: $0, response: $1, error: $2)
                        self.fulfill(promise: promise, for: result)
                    }
                    task.resume()
                } catch {
                    promise(.failure(error))
                }
            }
            .eraseToAnyPublisher()
        }
        .subscribe(on: subscriptionScheduler)
        .receive(on: receivingScheduler)
        .eraseToAnyPublisher()
    }
}

extension Service {
    func createURLRequest<Method: RequestMethod, Resource: RequestResource, Parameters: RequestParameters, Body: RequestBody, Key: ResponseNestedKey>(from request: HTTP._Request<Method, Resource, Parameters, Body, Key>) throws -> URLRequest {

        let url: URL
        switch request.resourceLocator {
        case let .relative(endpoint):
            guard let baseURL = self.url(given: endpoint) else {
                throw HTTPError.malformedURLString(endpoint, parameters: request.parameters)
            }
            url = endpoint.isEmpty ? baseURL : baseURL.appendingPathComponent(endpoint)
        case let .absolute(absoluteURL):
            url = absoluteURL
        }
        let finalURL: URL
        if request.parameters.isEmpty { finalURL = url }
        else {
            guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                throw HTTPError.malformedURL(url, parameters: request.parameters)
            }
            components.queryItems = request.parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            guard components.url != nil else {
                throw HTTPError.malformedURL(url, parameters: request.parameters)
            }
            finalURL = components.url!
        }
        let contentType = try request.data(typedEncoder: requestEncoder, dynamicEncoder: dynamicRequestEncodingStrategy)
        var urlRequest = URLRequest(url: finalURL)
        urlRequest.setValue(contentType?.mimeType.rawValue, forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = contentType?.data
        return urlRequest
    }
}

extension FileManager {
    var documentsDirectory: URL {
        return urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    var cachesDirectory: URL {
        return try! url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
}
