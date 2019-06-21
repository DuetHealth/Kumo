//
//  Service+SideEffects.swift
//  CNS
//
//  Created by ライアン on 11/13/18.
//  Copyright © 2018 Duet Health. All rights reserved.
//

import Foundation
import RxSwift

public extension Service {
    
    struct SideEffectScope {
        
        let base: Service
        
        init(_ base: Service) {
            self.base = base
        }
        
        @discardableResult func get(_ endpoint: String, parameters: [String: Any] = [:]) -> Disposable {
            return base.get(endpoint, parameters: parameters)
                .subscribe()
        }
        
        @discardableResult func post(_ endpoint: String, body: [String: Any]) -> Disposable {
            return base.post(endpoint, body: body)
                .subscribe()
        }
        
        @discardableResult func post<Body: Encodable>(_ endpoint: String, body: Body) -> Disposable {
            return (base.post(endpoint, body: body) as Observable<Void>)
                .subscribe()
        }
        
        @discardableResult func put<Body: Encodable>(_ endpoint: String, parameters: [String: Any] = [:], body: Body) -> Disposable {
            return (base.put(endpoint, parameters: parameters, body: body) as Observable<Void>)
                .subscribe()
        }
        
        @discardableResult func put(_ endpoint: String, parameters: [String: Any] = [:], body: [String: Any]) -> Disposable {
            return base.put(endpoint, parameters: parameters, body: body)
                .subscribe()
        }
        
        @discardableResult func delete(_ endpoint: String, parameters: [String: Any] = [:]) -> Disposable {
            return base.delete(endpoint, parameters: parameters)
                .subscribe()
        }
        
    }
    
    /// Provides a convenient way for performing requests which are side effects; that is, requests for which
    /// observing the response is unnecessary.
    var unobserved: SideEffectScope {
        return SideEffectScope(self)
    }
    
}
