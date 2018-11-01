//
//  RequestEncoding.swift
//  CNS
//
//  Created by ライアン on 10/29/18.
//  Copyright © 2018 Duet Health. All rights reserved.
//

import Foundation

public protocol RequestEncoding {
    var contentType: MIMEType { get }
    func encode<T: Encodable>(_ value: T) throws -> Data
}

extension JSONEncoder: RequestEncoding {
    
    public var contentType: MIMEType {
        return .applicationJSON(charset: .utf8)
    }
    
}
