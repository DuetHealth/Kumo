//
//  Service.swift
//  CNS
//
//  Created by ライアン on 10/16/18.
//  Copyright © 2018 Duet Health. All rights reserved.
//

import Chronicle
import Foundation
import RxCocoa
import RxSwift

public protocol RequestEncoding {
    var contentType: String { get }
    func encode<T: Encodable>(_ value: T) throws -> Data
}

public protocol RequestDecoding {
    var acceptType: String { get }
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}

extension JSONEncoder: RequestEncoding {
    
    public var contentType: String {
        return "application/json; charset=utf-8"
    }
    
}
extension JSONDecoder: RequestDecoding {
    
    public var acceptType: String {
        return "application/json; charset=utf-8"
    }
    
}

struct JSONWrapper<Inner: Decodable>: Decodable {

    let matchedKey: String
    let value: Inner
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        for key in container.allKeys {
            if let value = try? container.decode(Inner.self, forKey: key) {
                self.value = value
                matchedKey = key.stringValue
                return
            }
        }
        let context = DecodingError.Context(codingPath: container.codingPath, debugDescription: "A nested value of type \(Inner.self) was not found.")
        throw DecodingError.valueNotFound(Inner.self, context)
    }
    
}

public struct ServiceKey: Hashable {
    
    let stringValue: String
    
    public init(_ name: String) {
        self.stringValue = name
    }
}

public class Service {
    
    public let baseURL: URL
    private let delegate = URLSessionInvalidationDelegate()
    
    public var requestEncoder: RequestEncoding = JSONEncoder()
    public var requestDecoder: RequestDecoding = JSONDecoder()
    public var dynamicRequestEncodingStrategy: (Any) throws -> Data
    public var dynamicRequestDecodingStrategy: (Data) throws -> Any
    public var operationScheduler: SchedulerType = MainScheduler.instance
    private var session: URLSession
    
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
                    observer.on(self.dataTaskEvent(data: $0, response: $1, error: $2))
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
                    let event: Event<JSONWrapper<Response>> = self.dataTaskEvent(data: $0, response: $1, error: $2)
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
    
//    public func get<Response: Decodable>(_ endpoint: String, parameters: [String: Any] = [:]) -> Observable<[Response]> {
//        return Observable.create { [self] observer in
//            do {
//                let request = try self.createRequest(method: .get, endpoint: endpoint, queryParameters: parameters)
//                let task = self.session.dataTask(with: request) {
//                    observer.on(self.dataTaskEvent(data: $0, response: $1, error: $2))
//                    observer.onCompleted()
//                }
//
//                task.resume()
//                return Disposables.create(with: task.cancel)
//            } catch {
//                observer.onError(error)
//                return Disposables.create()
//            }
//        }
//    }
    
    public func post<Value, Response: Decodable>(_ endpoint: String, parameters: [String: Any] = [:], body: [String: Value]) -> Observable<Response> {
        return Observable.create { [self] observer in
            do {
                let request = try self.createRequest(method: .post, endpoint: endpoint, body: body)
                let task = self.session.dataTask(with: request) {
                    observer.on(self.dataTaskEvent(data: $0, response: $1, error: $2))
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
    
    public func post<Body: Encodable, Response: Decodable>(_ endpoint: String, parameters: [String: Any] = [:], body: Body) -> Observable<Response> {
        return Observable.create { [self] observer in
            do {
                let request = try self.createRequest(method: .post, endpoint: endpoint, body: body)
                let task = self.session.dataTask(with: request) {
                    observer.on(self.dataTaskEvent(data: $0, response: $1, error: $2))
                    observer.onCompleted()
                }
                Chronicle.main.network.debug(request)
                task.resume()
                return Disposables.create(with: task.cancel)
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
    
    private func dataTaskEvent<Response: Decodable>(data: Data?, response: URLResponse?, error: Error?) -> Event<Response> {
        if let error = error { return .error(error) }
        if let response = response { Chronicle.main.network.debug(response, data: data) }
        return data.map {
            do { return try .next(self.requestDecoder.decode(Response.self, from: $0)) }
            catch { return .error(error) }
        } ?? .completed
    }
    
}

class URLSessionInvalidationDelegate: NSObject, URLSessionDelegate {
    
    fileprivate var invalidations = [URLSession: (URLSession, Error?) -> ()]()
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        invalidations[session]?(session, error)
        invalidations[session] = nil
    }
    
}

fileprivate var temporaryDelegateKey = UInt8.max

extension URLSession {
    
    func finishTasksAndInvalidate(onInvalidation: @escaping (URLSession, Error?) -> ()) {
        guard let delegate = self.delegate as? URLSessionInvalidationDelegate else { return }
        delegate.invalidations[self] = onInvalidation
        finishTasksAndInvalidate()
    }
    
}

protocol ImmutableCopying {
    func copy() -> Self
}

protocol MutableCopying: ImmutableCopying {
    associatedtype MutableCopyType
    
    func mutableCopy() -> MutableCopyType
}

extension NSObject: ImmutableCopying { }

extension ImmutableCopying where Self: NSObject {
    
    func copy() -> Self {
        return (self as NSObject).copy() as! Self
    }
    
}
