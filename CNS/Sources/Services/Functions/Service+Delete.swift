//
//  Service+Delete.swift
//  CNS
//
//  Created by ライアン on 3/1/19.
//

import Foundation
import RxSwift

public extension Service {
    
    func delete<Response: Decodable>(_ endpoint: String, parameters: [String: Any] = [:]) -> Observable<Response> {
        return Observable.create { [self] observer in
            do {
                let request = try self.createRequest(method: .delete, endpoint: endpoint, queryParameters: parameters)
                let task = self.session.dataTask(with: request) {
                    observer.on(self.resultToElement(data: $0, response: $1, error: $2))
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
    
    func delete(_ endpoint: String, parameters: [String: Any] = [:]) -> Observable<Void> {
        return Observable.create { [self] observer in
            do {
                let request = try self.createRequest(method: .delete, endpoint: endpoint, queryParameters: parameters)
                let task = self.session.dataTask(with: request) {
                    observer.on(self.resultToEvent(data: $0, response: $1, error: $2))
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
    
}
