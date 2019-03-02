//
//  Service+Post.swift
//  CNS
//
//  Created by ライアン on 3/1/19.
//

import Foundation
import RxSwift

public extension Service {
    
    public func post<Body: Encodable, Response: Decodable>(_ endpoint: String, parameters: [String: Any] = [:], body: Body) -> Observable<Response> {
        return Observable.create { [self] observer in
            do {
                let request = try self.createRequest(method: .post, endpoint: endpoint, body: body)
                let task = self.session.dataTask(with: request) {
                    observer.on(self.resultToElement(data: $0, response: $1, error: $2))
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
                    observer.on(self.resultToEvent(data: $0, response: $1, error: $2))
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
                    observer.on(self.resultToElement(data: $0, response: $1, error: $2))
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
    
    public func post<Body: Encodable>(_ endpoint: String, parameters: [String: Any] = [:], body: Body) -> Observable<Any> {
        return Observable.create { [self] observer in
            do {
                let request = try self.createRequest(method: .post, endpoint: endpoint, body: body)
                let task = self.session.dataTask(with: request) {
                    observer.on(self.resultToElement(data: $0, response: $1, error: $2))
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
                    observer.on(self.resultToEvent(data: $0, response: $1, error: $2))
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
    

    
}
