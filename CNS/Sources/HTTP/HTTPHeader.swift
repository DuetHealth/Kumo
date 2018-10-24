//
//  HTTPHeader.swift
//  CNS
//
//  Created by ライアン on 10/23/18.
//  Copyright © 2018 Duet Health. All rights reserved.
//

import Foundation

public struct HTTPHeader: Hashable {
    
    public static let authorization = HTTPHeader(rawValue: "Authorization")
    
    public static func custom(_ value: String) -> HTTPHeader {
        return HTTPHeader(rawValue: value)
    }
    
    let rawValue: String
    
    fileprivate init(rawValue: String) {
        self.rawValue = rawValue
    }
    
}

public extension URLSessionConfiguration {
    
    public var httpHeaders: [HTTPHeader: Any]? {
        get {
            return httpAdditionalHeaders.map {
                Dictionary(uniqueKeysWithValues: $0.flatMap { pair in
                    guard let string = pair.key.base as? String else { return nil }
                    return (HTTPHeader(rawValue: string), pair.value)
                })
            }
        }
        set {
            httpAdditionalHeaders = newValue.map {
                Dictionary(uniqueKeysWithValues: $0.map { pair in
                    return (AnyHashable(pair.key), pair.value)
                })
            }
        }
    }
    
}
