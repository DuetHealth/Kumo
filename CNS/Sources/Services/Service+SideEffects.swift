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
            return base.post(endpoint, body: parameters)
                .subscribe()
        }
        
    }
    
    /// Provides a convenient way for performing requests which are side-effects: ignored
    public var unobserved: SideEffectScope {
        return SideEffectScope(self)
    }
    
}
