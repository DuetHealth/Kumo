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

public protocol Encoding {
    func encode<T: Encodable>(_ value: T) throws -> Data
}

public protocol Decoding {
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}

extension JSONEncoder: Encoding { }
extension JSONDecoder: Decoding { }

public struct ServiceKey: Hashable {
    
    let stringValue: String
    
    public init(_ name: String) {
        self.stringValue = name
    }
}

public class Service {
    
    public let baseURL: URL
    private let delegate = URLSessionInvalidationDelegate()
    
    public var requestEncoder: Encoding = JSONEncoder()
    public var requestDecoder: Decoding = JSONDecoder()
    public var dynamicRequestEncodingStrategy: (Any) throws -> Data
    public var dynamicRequestDecodingStrategy: (Data) throws -> Any
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
    }
    
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
        request.httpMethod = method.rawValue
        request.httpBody = body
        return request
    }
    
    private func dataTaskEvent<Response: Decodable>(data: Data?, response: URLResponse?, error: Error?) -> Event<Response> {
        if let error = error { return .error(error) }
        Chronicle.main.network.debug(<#T##response: URLResponse##URLResponse#>, responseObject: <#T##NSDictionary#>, method: <#T##String#>)
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
    }
    
}

fileprivate var temporaryDelegateKey = UInt8.max

extension URLSession {
    
    func finishTasksAndInvalidate(onInvalidation: @escaping (URLSession, Error?) -> ()) {
        guard let delegate = self.delegate as? URLSessionInvalidationDelegate else { return }
        delegate.invalidations[self] = onInvalidation
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
