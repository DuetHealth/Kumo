//
//  UnkeyedEncodingContainer+DynamicEncoding.swift
//  DHKApi
//
//  Created by Ryan Wachowski on 8/6/18.
//  Copyright © 2018 Duet Health. All rights reserved.
//

import Foundation

public extension UnkeyedEncodingContainer {

    mutating func encode(_ value: [String: Any], strategy: DynamicKeyStrategy = .default) throws {
        var container = nestedContainer(keyedBy: DynamicCodingKeys.self)
        try container.encode(value, strategy: strategy)
    }

    mutating func encode(_ value: [Any], strategy: DynamicKeyStrategy = .default) throws {
        try value.forEach {
            if let dictionary = $0 as? [String: Any] {
                try encode(dictionary, strategy: strategy)
            } else if let array = $0 as? [Any] {
                try encode(array, strategy: strategy)
            } else if let encodable = $0 as? Encodable {
                try encode(ErasedEncodable(encodable))
            } else {
                let codingPath = self.codingPath
                let context = EncodingError.Context(codingPath: codingPath, debugDescription: "The value at index \(count) is not encodable.")
                throw EncodingError.invalidValue($0, context)
            }
        }
    }

}
