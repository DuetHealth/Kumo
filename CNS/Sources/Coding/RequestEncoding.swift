//
//  RequestEncoding.swift
//  CNS
//
//  Created by ライアン on 10/29/18.
//  Copyright © 2018 Duet Health. All rights reserved.
//

import Foundation

public protocol RequestEncoding {
    var contentType: String { get }
    func encode<T: Encodable>(_ value: T) throws -> Data
}

extension JSONEncoder: RequestEncoding {
    
    public var contentType: String {
        return "application/json; charset=utf-8"
    }
    
}
