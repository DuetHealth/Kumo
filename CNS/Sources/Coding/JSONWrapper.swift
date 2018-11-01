//
//  JSONWrapper.swift
//  CNS
//
//  Created by ライアン on 10/29/18.
//  Copyright © 2018 Duet Health. All rights reserved.
//

import Foundation

struct JSONWrapper<Inner: Decodable>: Decodable {
    
    let matchedKey: String
    let value: Inner
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        for key in container.allKeys {
            do {
                value = try container.decode(Inner.self, forKey: key)
                matchedKey = key.stringValue
                return
            } catch {
                print(error)
            }
//            if let value = try? container.decode(Inner.self, forKey: key) {
//
//            }
        }
        let context = DecodingError.Context(codingPath: container.codingPath, debugDescription: "A nested value of type \(Inner.self) was not found.")
        throw DecodingError.valueNotFound(Inner.self, context)
    }
    
}
