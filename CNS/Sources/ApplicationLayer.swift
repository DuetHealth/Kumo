//
//  ApplicationLayer.swift
//  CNS
//
//  Created by ライアン on 10/16/18.
//  Copyright © 2018 Duet Health. All rights reserved.
//

import Foundation

open class ApplicationLayer {
    
    private var commonHeaders = [String: String]()
    private var kernels = [ServiceKey: Service]()
    
    public init(with kernels: [ServiceKey: Service] = [:]) {
        self.kernels = kernels
    }
    
    public subscript(_ key: ServiceKey) -> Service {
        return kernels[key]!
    }
    
}
