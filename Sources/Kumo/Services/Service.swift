import Combine
import Foundation

#if canImport(KumoCoding)
import KumoCoding
#endif

/// A key representing a given service.
public struct ServiceKey: Hashable {

    let stringValue: String

    /// Creates a key named: `name`.
    public init(_ name: String) {
        stringValue = name
    }

}

/// A structure that wraps the error returned from a response as well as the
/// `URLResponse`.
public struct ResponseObjectError: Error {

    public let responseObject: URLResponse?
    public let wrappedError: Error

    init(error: Error, responseObject: URLResponse?) {
        self.responseObject = responseObject
        wrappedError = error
    }

    public var localizedDescription: String {
        wrappedError.localizedDescription
    }

}

/// A wrapper for networking centered around a ``baseURL`` among other
/// service-level configuration options.
public class Service {

    /// The base URL for all requests.
    public let baseURL: URL?
    
    
    /// Key to enable AB testing invalidation
    public static var isSafeInvalidationEnabled = false

    /// The type of error returned by the server. When a response returns an
    /// error status code, the service will attempt to decode the body of the
    /// response as this type.
    ///
    /// The default value of this is `nil`. If no type is set, the service will
    /// not attempt to decode an error body.
    public var errorType = ResponseError?.none

    /// The object which encodes request bodies which conform to the `Encodable`
    /// protocol.
    ///
    /// The default instance is a [`JSONEncoder`](https://developer.apple.com/documentation/foundation/jsonencoder).
    public var requestEncoder: RequestEncoding = JSONEncoder()

    /// The object which decodes response bodies which conform to the
    /// `Decodable` protocol.
    ///
    /// The default instance is a [`JSONDecoder`](https://developer.apple.com/documentation/foundation/jsondecoder).
    public var requestDecoder: RequestDecoding = JSONDecoder()

    /// The behavior to use for encoding dynamically-typed request bodies.
    ///
    /// The default implementation uses Foundation's ``JSONSerialization`.
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

    /// The characters to be allowed in the query section of request URLs.
    public var urlQueryAllowedCharacters = CharacterSet.urlQueryAllowed

    /// The logger to log the network requests and any errors
    public var logger: KumoLogger?

    /// Returns the headers applied to all requests.
    public var commonHTTPHeaders: [HTTP.Header: Any]? {
        session.configuration.httpHeaders
    }

    private var delegate: URLSessionDelegate = URLSessionInvalidationDelegate()

    private let invalidationQueue = DispatchQueue(label: "DuetHealth.session.synchronization")
    private let invalidationSemaphore = DispatchSemaphore(value: 1)

    private var session: URLSession {
        invalidationQueue.sync {
            return _session
        }
    }
    
    private(set) var _session: URLSession

    /// Creates a service with the specified ``baseURL``.
    /// - Parameters:
    ///   - baseURL: The base URL for all requests. The URLs for requests
    ///   performed by the service are made by appending path components to
    ///   this URL.
    ///   - runsInBackground: Sets whether uploads / downloads are to be
    ///   performed in the background.
    ///   - logger: Sets the the KumoLogger for the service.
    ///   - delegateQueue sets the `OperationQueue` for the `URLSession`
    ///   - configuration: A block for making initial modifications to the
    ///   [`URLSessionConfiguration`](https://developer.apple.com/documentation/foundation/urlsessionconfiguration).
    public init(baseURL: URL?, runsInBackground: Bool = false, logger: KumoLogger? = nil, delegateQueue: OperationQueue? = nil, configuration: ((URLSessionConfiguration) -> Void)? = nil) {
        self.baseURL = baseURL
        // Do not set the logger if there are not logging levels set
        if logger?.levels.isEmpty == true {
            self.logger = nil
        } else {
            self.logger = logger
        }
        let sessionConfiguration = runsInBackground ? URLSessionConfiguration.background(withIdentifier: baseURL?.absoluteString ?? UUID().uuidString) : .default
        configuration?(sessionConfiguration)
        if Service.isSafeInvalidationEnabled {
            delegate = URLSessionThreadSafeInvalidationDelegate()
        }
        _session = URLSession(configuration: sessionConfiguration, delegate: delegate, delegateQueue: delegateQueue)
        dynamicRequestEncodingStrategy = { object in
            try JSONSerialization.data(withJSONObject: object, options: [])
        }
        dynamicRequestDecodingStrategy = { data in
            try JSONSerialization.jsonObject(with: data, options: [])
        }
    }

    internal func copySettings(from _: ApplicationLayer) { }

    /// Update the header with value for HTTP.Header type
    /// - Parameters:
    ///   - value: any vlaue for the HTTP.Header
    public func updateHeader(value: Any, for header: HTTP.Header) {
        session.configuration.headers.set(value: String(describing: value), for: header)
    }

    /// Provides a way to reconfigure the URLSessionConfiguration that powers
    /// the Service.
    public func reconfigure(applying changes: @escaping (URLSessionConfiguration) -> Void) {
        invalidationQueue.sync {
            invalidationSemaphore.wait()
            _session.finishTasksAndInvalidate { [unowned self] session, _ in
                let newConfiguration: URLSessionConfiguration = session.configuration.copy()
                changes(newConfiguration)
                self._session = URLSession(configuration: newConfiguration, delegate: self.delegate, delegateQueue: nil)
                self.invalidationSemaphore.signal()
            }
        }
    }

    /// Provides a way to asynchronously reconfigure the
    /// [`URLSessionConfiguration`](https://developer.apple.com/documentation/foundation/urlsessionconfiguration)
    /// that powers the Service. Prefer this over ``reconfigure(applying:)``
    /// when making a request that will modify the session configuration based
    /// on the result of the request, e.g.: upon logging in and receiving a
    /// token that will be added to subsequent headers.
    public func reconfiguring(applying changes: @escaping (URLSessionConfiguration) -> Void) -> AnyPublisher<Void, Never> {
        Future<Void, Never> { [weak self] promise in
            guard let self = self else {
                promise(.success(()))
                return
            }
            self.invalidationQueue.sync {
                self.invalidationSemaphore.wait()
                self._session.finishTasksAndInvalidate { [unowned self] session, _ in
                    let newConfiguration: URLSessionConfiguration = session.configuration.copy()
                    changes(newConfiguration)
                    self._session = URLSession(configuration: newConfiguration, delegate: self.delegate, delegateQueue: nil)
                    promise(.success(()))
                    self.invalidationSemaphore.signal()
                }
            }
        }
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

    /// Converts the results of a `URLSessionDataTask` into a `Result` with
    /// which consumers may perform side effects.
    func result(data: Data?, response: URLResponse?, error: Error?) -> Result<Void, Error> {
        if let response = response {
            logger?.logResponse(response)
        }
        if let error = error {
            logger?.logResponseError(error)
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
        return .success(())
    }

    /// Converts the results of a `URLSessionDataTask` into a `Result` with
    /// which consumers may act on an element.
    private func result<Response: Decodable>(data: Data?, response: URLResponse?, error: Error?) -> Result<Response, Error> {
        if let response = response {
            logger?.logResponse(response)
        }
        if let error = error {
            logger?.logResponseError(error)
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
        logger?.logRawResponse(data)
        return data.map {
            do { return try .success(self.requestDecoder.decode(Response.self, from: $0)) }
            catch { return .failure(ResponseObjectError(error: error, responseObject: response)) }
        } ?? .failure(ResponseObjectError(error: HTTPError.ambiguousError(httpResponse.status), responseObject: response))
    }

    /// Converts the results of a `URLSessionDataTask` into a `Result` with
    /// which consumers may act on an element.
    func result(data: Data?, response: URLResponse?, error: Error?) -> Result<Any, Error> {
        if let response = response {
            logger?.logResponse(response)
        }
        if let error = error {
            logger?.logResponseError(error)
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
        logger?.logRawResponse(data)
        return data.map {
            do { return try .success(self.dynamicRequestDecodingStrategy($0)) }
            catch { return .failure(ResponseObjectError(error: error, responseObject: response)) }
        } ?? .failure(ResponseObjectError(error: HTTPError.ambiguousError(httpResponse.status), responseObject: response))
    }

    /// Converts the results of a `URLSessionDownloadTask` into a `Result`
    /// with which consumer may act on an element.
    func downloadResultToURL(url: URL?, response: URLResponse?, error: Error?) -> Result<URL, Error> {
        if let response = response {
            logger?.logResponse(response)
        }
        if let error = error {
            logger?.logResponseError(error)
            return .failure(error)
        }
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
        if let url = baseURL {
            return url
        }
        return URL(string: endpoint)
    }
}

public extension Service {

    internal func fulfill<T>(promise: Future<T, Error>.Promise, for result: Result<T, Error>) {
        switch result {
        case let .failure(error):
            promise(.failure(error))
        case let .success(value): promise(.success(value))
        }
    }

    /// Performs the passed in HTTP `request`.
    /// - Returns: A publisher for the decoded response.
    func perform<Response: Decodable, Method: _RequestMethod, Resource: _RequestResource, Parameters: _RequestParameters, Body: _RequestBody, Key: _ResponseNestedKey>(_ request: HTTP
        ._Request<Method, Resource, Parameters, Body, Key>) -> AnyPublisher<Response, Error> {
        Deferred<AnyPublisher<Response, Error>> {
            Future<Response, Error> { promise in
                let urlRequest: URLRequest
                do {
                    urlRequest = try self.createURLRequest(from: request)
                    self.logger?.logRequest(urlRequest)
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
        .logPublisher(logger)
        .eraseToAnyPublisher()
    }

    /// Performs the passed in HTTP `request`.
    /// - Returns: A publisher that emits when the request has finished.
    func perform<Method: _RequestMethod, Resource: _RequestResource, Parameters: _RequestParameters, Body: _RequestBody, Key: _ResponseNestedKey>(_ request: HTTP
        ._Request<Method, Resource, Parameters, Body, Key>) -> AnyPublisher<Void, Error> {
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
        .logPublisher(logger)
        .eraseToAnyPublisher()
    }

    /// Performs the passed in HTTP `request`.
    /// - Returns: A publisher for the decoded response.
    func perform<Method: _RequestMethod, Resource: _RequestResource, Parameters: _RequestParameters, Body: _RequestBody, Key: _ResponseNestedKey>(_ request: HTTP
        ._Request<Method, Resource, Parameters, Body, Key>) -> AnyPublisher<Any, Error> {
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
        .logPublisher(logger)
        .eraseToAnyPublisher()
    }

    /// Performs the passed in HTTP download `request`.
    /// - Returns: A publisher for a file `URL` for the downloaded resource.
    func perform<Resource: _RequestResource, Parameters: _RequestParameters>(_ request: HTTP._DownloadRequest<Resource, Parameters>) -> AnyPublisher<URL, Error> {
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
        .logPublisher(logger)
        .eraseToAnyPublisher()
    }

    /// Performs the passed in HTTP multipart form upload `request`.
    /// - Returns: A publisher for the decoded response.
    func perform<Response: Decodable, Resource: _RequestResource, Parameters: _RequestParameters, Body: _RequestBody, Name: _RequestDispositionName>(_ request: HTTP
        ._UploadRequest<Resource, Parameters, Body, Name, _NoOption>) -> AnyPublisher<Response, Error> {
        Deferred<AnyPublisher<Response, Error>> {
            Future<Response, Error> { [self] promise in
                do {
                    var urlRequest = try self.createURLRequest(from: request.baseRepresentation)
                    guard let file = request.file else { fatalError("Generics should guarantee that uploads only happen when a body / file is specified.") }
                    guard let key = request.key else { fatalError("Generics should guarantee that uploads only happen when a disposition key is specified.") }
                    guard file.isFileURL else { throw UploadError.notAFileURL(file) }
                    let form = try MultipartForm(file: file, under: key, encoding: .utf8)
                    urlRequest.set(contentType: .multipartFormData(boundary: form.boundary))
                    let task = self.session.uploadTask(with: urlRequest, from: form.data) {
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
        .logPublisher(logger)
        .eraseToAnyPublisher()
    }

    /// Performs the passed in HTTP multipart form upload `request`.
    /// - Returns: A publisher that emits when the upload has finished.
    func perform<Resource: _RequestResource, Parameters: _RequestParameters, Body: _RequestBody, Name: _RequestDispositionName>(_ request: HTTP
        ._UploadRequest<Resource, Parameters, Body, Name, _NoOption>) -> AnyPublisher<Void, Error> {
        Deferred<AnyPublisher<Void, Error>> {
            Future<Void, Error> { promise in
                do {
                    var urlRequest = try self.createURLRequest(from: request.baseRepresentation)
                    guard let file = request.file else { fatalError("Generics should guarantee that uploads only happen when a body / file is specified.") }
                    guard let key = request.key else { fatalError("Generics should guarantee that uploads only happen when a disposition key is specified.") }
                    guard file.isFileURL else { throw UploadError.notAFileURL(file) }
                    let form = try MultipartForm(file: file, under: key, encoding: .utf8)
                    urlRequest.set(contentType: .multipartFormData(boundary: form.boundary))
                    let task = self.session.uploadTask(with: urlRequest, from: form.data) {
                        let result: Result<Void, Error> = self.result(data: $0, response: $1, error: $2)
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
        .logPublisher(logger)
        .eraseToAnyPublisher()
    }

    /// Performs the passed in HTTP multipart form upload `request`.
    /// - Returns: A publisher that updates with the upload progress.
    func perform<Resource: _RequestResource, Parameters: _RequestParameters, Body: _RequestBody, Name: _RequestDispositionName>(_ request: HTTP
        ._UploadRequest<Resource, Parameters, Body, Name, _HasOption>) -> AnyPublisher<Double, Error> {
        Deferred<AnyPublisher<URLSessionUploadTask, Error>> {
            AnyPublisher<URLSessionUploadTask, Error>.create { subscriber in
                var task = URLSessionUploadTask?.none
                do {
                    var urlRequest = try self.createURLRequest(from: request.baseRepresentation)
                    guard let file = request.file else { fatalError("Generics should guarantee that uploads only happen when a body / file is specified.") }
                    guard let key = request.key else { fatalError("Generics should guarantee that uploads only happen when a disposition key is specified.") }
                    guard file.isFileURL else { throw UploadError.notAFileURL(file) }
                    let form = try MultipartForm(file: file, under: key, encoding: .utf8)
                    urlRequest.set(contentType: .multipartFormData(boundary: form.boundary))
                    task = self.session.uploadTask(with: urlRequest, from: form.data) {
                        let result: Result<Void, Error> = self.result(data: $0, response: $1, error: $2)
                        switch result {
                        case let .failure(error): subscriber.onError(error)
                        case .success: subscriber.onComplete()
                        }
                    }
                    guard let task = task else { return AnyCancellable { } }
                    subscriber.onNext(task)
                    task.resume()
                } catch {
                    subscriber.onError(error)
                }
                return AnyCancellable {
                    task?.cancel()
                }
            }
        }
        .map {
            $0.progress.kumo.fractionComplete
                .eraseToAnyPublisher()
                .setFailureType(to: Error.self)
        }
        .switchToLatest()
        .logPublisher(logger)
        .eraseToAnyPublisher()
    }

}

extension Service {
    func createURLRequest<Method: _RequestMethod, Resource: _RequestResource, Parameters: _RequestParameters, Body: _RequestBody, Key: _ResponseNestedKey>(from request: HTTP
        ._Request<Method, Resource, Parameters, Body, Key>) throws -> URLRequest {
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
        urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    var cachesDirectory: URL {
        try! url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
}
