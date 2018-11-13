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
    
    public struct SideEffectScope {
        
        let base: Service
        
        init(_ base: Service) {
            self.base = base
        }
        
        @discardableResult public func get(_ endpoint: String, parameters: [String: Any] = [:]) -> Disposable {
            return base.get(endpoint, parameters: parameters)
                .subscribe()
        }
        
        @discardableResult public func post(_ endpoint: String, body: [String: Any]) -> Disposable {
            return base.post(endpoint, body: body)
                .subscribe()
        }
        
        @discardableResult public func post<Body: Encodable>(_ endpoint: String, body: Body) -> Disposable {
            return (base.post(endpoint, body: body) as Observable<Void>)
                .subscribe()
        }
        
    }
    
    /// Provides a convenient way for performing requests which are side effects; that is, requests for which
    /// observing the response is unnecessary.
    public var unobserved: SideEffectScope {
        return SideEffectScope(self)
    }
    
}
