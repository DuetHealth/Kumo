//
//  RequestDecoding.swift
//  CNS
//
//  Created by ライアン on 10/29/18.
//  Copyright © 2018 Duet Health. All rights reserved.
//

import Foundation

public protocol RequestDecoding {
    var acceptType: String { get }
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}

extension JSONDecoder: RequestDecoding {
    
    public var acceptType: String {
        return "application/json; charset=utf-8"
    }
    
}
