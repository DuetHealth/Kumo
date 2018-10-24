//
//  UnkeyedDecoding+DynamicDecoding.swift
//  DHKApi
//
//  Created by Ryan Wachowski on 8/6/18.
//  Copyright © 2018 Duet Health. All rights reserved.
//

import Foundation

public extension UnkeyedDecodingContainer {

    public mutating func decode(_ type: [Any].Type, strategy: DynamicKeyStrategy = .camelToSnakeCase) throws -> [Any] {
        var result = [Any]()
        while !isAtEnd {
            if try decodeNil() { continue }
            else if let bool = try? decode(Bool.self) { result.append(bool) }
            else if let string = try? decode(String.self) { result.append(string) }
            else if let int = try? decode(Int.self) { result.append(int) }
            else if let double = try? decode(Double.self) { result.append(double) }
            else if let dictionary = try? decode([String: Any].self, strategy: strategy) { result.append(dictionary) }
            else if let array = try? decode([Any].self, strategy: strategy) { result.append(array) }
            else {
                let context = DecodingError.Context(codingPath: codingPath, debugDescription: "The value at index \(count) is not decodable.")
                throw DecodingError.dataCorrupted(context)
            }
        }
        return result
    }

    public mutating func decode(_ type: [String: Any].Type, strategy: DynamicKeyStrategy = .camelToSnakeCase) throws -> [String: Any] {
        let container = try nestedContainer(keyedBy: DynamicCodingKeys.self)
        return try container.decode(type, strategy: strategy)
    }

}
