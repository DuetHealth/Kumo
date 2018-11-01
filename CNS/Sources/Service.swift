//
//  Service.swift
//  CNS
//
//  Created by ライアン on 10/16/18.
//  Copyright © 2018 Duet Health. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public struct ServiceKey: Hashable {
    
    let stringValue: String
    
    public init(_ name: String) {
        self.stringValue = name
    }
    
}

public struct ResponseError {
    
    let type: (Error & Decodable).Type
    private let implementation: (Data, RequestDecoding) throws -> Error
    
    public init<T: Error & Decodable>(_ type: T.Type) {
        self.type = type
        implementation = { data, decoding in
            try decoding.decode(T.self, from: data)
        }
    }
    
    func decode(data: Data, with decoding: RequestDecoding) throws -> Error {
        return try implementation(data, decoding)
    }
    
}

public class Service {
    
    /// The base URL for all requests. The URLs for requests performed by the service are made
    /// by appending path components to this URL.
    public let baseURL: URL
    
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
    
    /// The scheduler on which to observe tasks.
    ///
    /// By default, tasks are observed on the main thread.
    public var operationScheduler: SchedulerType = MainScheduler.instance
    
    private var session: URLSession
    
    /// Returns the headers applied to all requests.
    public var commonHTTPHeaders: [HTTPHeader: Any]? {
        return session.configuration.httpHeaders
    }
    
    public init(baseURL: URL, configuration: ((URLSessionConfiguration) -> ())? = nil) {
        self.baseURL = baseURL
        let sessionConfiguration = URLSessionConfiguration.default
        configuration?(sessionConfiguration)
        session = URLSession(configuration: sessionConfiguration, delegate: delegate, delegateQueue: nil)
        dynamicRequestEncodingStrategy = { object in
            return try JSONSerialization.data(withJSONObject: object, options: [])
        }
        dynamicRequestDecodingStrategy = { data in
            return try JSONSerialization.jsonObject(with: data, options: [])
        }
    }
    
    internal func copySettings(from applicationLayer: ApplicationLayer) {
        
    }
    
    public func reconfigure(applying changes: @escaping (URLSessionConfiguration) -> ()) {
        session.finishTasksAndInvalidate { [unowned self] session, _ in
            let newConfiguration: URLSessionConfiguration = session.configuration.copy()
            changes(newConfiguration)
            self.session = URLSession(configuration: newConfiguration, delegate: self.delegate, delegateQueue: nil)
        }
    }
    
    public func get<Response: Decodable>(_ endpoint: String, parameters: [String: Any] = [:]) -> Observable<Response> {
        return Observable.create { [self] observer in
            do {
                let request = try self.createRequest(method: .get, endpoint: endpoint, queryParameters: parameters)
                let task = self.session.dataTask(with: request) {
                    observer.on(self.dataTaskToElement(data: $0, response: $1, error: $2))
                    observer.onCompleted()
                }
                task.resume()
                return Disposables.create(with: task.cancel)
            } catch {
                observer.onError(error)
                return Disposables.create()
            }
        }
            .observeOn(operationScheduler)
    }
    
    public func get<Response: Decodable>(_ endpoint: String, parameters: [String: Any] = [:], keyedUnder key: String) -> Observable<Response> {
        return Observable.create { [self] observer in
            do {
                let request = try self.createRequest(method: .get, endpoint: endpoint, queryParameters: parameters)
                let task = self.session.dataTask(with: request) {
                    let event: Event<JSONWrapper<Response>> = self.dataTaskToElement(data: $0, response: $1, error: $2)
                    switch event {
                    case .error(let error): return observer.onError(error)
                    case .completed: return observer.onCompleted()
                    case .next(let wrapper):
                        if wrapper.matchedKey == key { observer.onNext(wrapper.value) }
                        else {
                            let context = DecodingError.Context(codingPath: [], debugDescription: "Tried to find data nested under \(key) but found it under \(wrapper.matchedKey)")
                            observer.onError(DecodingError.keyNotFound(DynamicCodingKeys(stringValue: key)!, context))
                        }
                        observer.onCompleted()
                    }
                }
                task.resume()
                return Disposables.create(with: task.cancel)
            } catch {
                observer.onError(error)
                return Disposables.create()
            }
        }
            .observeOn(operationScheduler)
    }
    
    public func post<Body: Encodable, Response: Decodable>(_ endpoint: String, parameters: [String: Any] = [:], body: Body) -> Observable<Response> {
        return Observable.create { [self] observer in
            do {
                let request = try self.createRequest(method: .post, endpoint: endpoint, body: body)
                let task = self.session.dataTask(with: request) {
                    observer.on(self.dataTaskToElement(data: $0, response: $1, error: $2))
                    observer.onCompleted()
                }
                task.resume()
                return Disposables.create(with: task.cancel)
            } catch {
                observer.onError(error)
                return Disposables.create()
            }
        }
            .observeOn(operationScheduler)
    }
    
    public func post<Body: Encodable>(_ endpoint: String, parameters: [String: Any] = [:], body: Body) -> Observable<Void> {
        return Observable.create { [self] observer in
            do {
                let request = try self.createRequest(method: .post, endpoint: endpoint, body: body)
                let task = self.session.dataTask(with: request) {
                    observer.on(self.dataTaskToEvent(data: $0, response: $1, error: $2))
                    observer.onCompleted()
                }
                task.resume()
                return Disposables.create(with: task.cancel)
            } catch {
                observer.onError(error)
                return Disposables.create()
            }
        }
            .observeOn(operationScheduler)
    }
    
    public func post<Response: Decodable>(_ endpoint: String, parameters: [String: Any] = [:], body: [String: Any]) -> Observable<Response> {
        return Observable.create { [self] observer in
            do {
                let request = try self.createRequest(method: .post, endpoint: endpoint, body: body)
                let task = self.session.dataTask(with: request) {
                    observer.on(self.dataTaskToElement(data: $0, response: $1, error: $2))
                    observer.onCompleted()
                }
                task.resume()
                return Disposables.create(with: task.cancel)
            } catch {
                observer.onError(error)
                return Disposables.create()
            }
        }
            .observeOn(operationScheduler)
    }
    
    public func post(_ endpoint: String, parameters: [String: Any] = [:], body: [String: Any]) -> Observable<Void> {
        return Observable.create { [self] observer in
            do {
                let request = try self.createRequest(method: .post, endpoint: endpoint, body: body)
                let task = self.session.dataTask(with: request) {
                    observer.on(self.dataTaskToEvent(data: $0, response: $1, error: $2))
                    observer.onCompleted()
                }
                task.resume()
                return Disposables.create(with: task.cancel)
            } catch {
                observer.onError(error)
                return Disposables.create()
            }
        }
            .observeOn(operationScheduler)
    }
    
    public func put<Body: Encodable, Response: Decodable>(_ endpoint: String, parameters: [String: Any] = [:], body: Body) -> Observable<Response> {
        return Observable.create { [self] observer in
            do {
                let request = try self.createRequest(method: .put, endpoint: endpoint, queryParameters: parameters, body: body)
                let task = self.session.dataTask(with: request) {
                    observer.on(self.dataTaskToElement(data: $0, response: $1, error: $2))
                    observer.onCompleted()
                }
                task.resume()
                return Disposables.create(with: task.cancel)
            } catch {
                observer.onError(error)
                return Disposables.create()
            }
        }
            .observeOn(operationScheduler)
    }
    
    public func put<Body: Encodable>(_ endpoint: String, parameters: [String: Any] = [:], body: Body) -> Observable<Void> {
        return Observable.create { [self] observer in
            do {
                let request = try self.createRequest(method: .put, endpoint: endpoint, queryParameters: parameters, body: body)
                let task = self.session.dataTask(with: request) {
                    observer.on(self.dataTaskToEvent(data: $0, response: $1, error: $2))
                    observer.onCompleted()
                }
                task.resume()
                return Disposables.create()
            } catch {
                observer.onError(error)
                return Disposables.create()
            }
        }
            .observeOn(operationScheduler)
    }
    
    private func createRequest(method: HTTPMethod, endpoint: String, queryParameters: [String: Any] = [:], body: [String: Any]? = nil) throws -> URLRequest {
        let data: Data?
        do { data = try body.map(dynamicRequestEncodingStrategy) }
        catch { throw HTTPError.unserializableRequestBody(object: body, originalError: error) }
        return try createRequest(method: method, endpoint: endpoint, queryParameters: queryParameters, body: data)
    }
    
    private func createRequest<Body: Encodable>(method: HTTPMethod, endpoint: String, queryParameters: [String: Any] = [:], body: Body? = nil) throws -> URLRequest {
        let data: Data?
        do { data = try body.map(requestEncoder.encode) }
        catch { throw HTTPError.unserializableRequestBody(object: body, originalError: error) }
        return try createRequest(method: method, endpoint: endpoint, queryParameters: queryParameters, body: data)
    }
    
    private func createRequest(method: HTTPMethod, endpoint: String, queryParameters: [String: Any], body: Data?) throws -> URLRequest {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(endpoint), resolvingAgainstBaseURL: false) else {
            throw HTTPError.malformedURL(baseURL: baseURL, endpoint: endpoint)
        }
        components.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint))
        request.httpHeaders = [.contentType: requestEncoder.contentType,
                               .accept: requestDecoder.acceptType]
        request.httpMethod = method.rawValue
        request.httpBody = body
        return request
    }
    
    /// Converts the results of a `URLSessionDataTask` into an Rx `Event` with which consumers may
    /// perform side effects.
    private func dataTaskToEvent(data: Data?, response: URLResponse?, error: Error?) -> Event<Void> {
        if let error = error { return .error(error) }
        guard let httpResponse = response as? HTTPURLResponse else {
            return .error(response == nil ? HTTPError.emptyResponse : HTTPError.unsupportedResponse)
        }
        if httpResponse.status.isError {
            return errorType.flatMap { type in
                data.map {
                    do { return try .error(type.decode(data: $0, with: requestDecoder)) }
                    catch { return .error(HTTPError.corruptedError(type.type, decodingError: error)) }
                    } ?? .error(HTTPError.ambiguousError(httpResponse.status))
                } ?? .error(HTTPError.ambiguousError(httpResponse.status))
        }
        return .next(())
    }
    
    /// Converts the results of a `URLSessionDataTask` into an Rx `Event` with which consumers may
    /// act on an element.
    private func dataTaskToElement<Response: Decodable>(data: Data?, response: URLResponse?, error: Error?) -> Event<Response> {
        if let error = error { return .error(error) }
        guard let httpResponse = response as? HTTPURLResponse else {
            return .error(response == nil ? HTTPError.emptyResponse : HTTPError.unsupportedResponse)
        }
        if httpResponse.status.isError {
            return errorType.flatMap { type in
                data.map {
                    do { return try .error(type.decode(data: $0, with: requestDecoder)) }
                    catch { return .error(HTTPError.corruptedError(type.type, decodingError: error)) }
                } ?? .error(HTTPError.ambiguousError(httpResponse.status))
            } ?? .error(HTTPError.ambiguousError(httpResponse.status))
        }
        return data.map {
            do { return try .next(self.requestDecoder.decode(Response.self, from: $0)) }
            catch { return .error(error) }
        } ?? .completed
    }
    
}
