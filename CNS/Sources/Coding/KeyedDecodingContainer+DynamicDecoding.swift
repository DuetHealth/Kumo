//
//  KeyedDecodingContainer+DynamicDecoding.swift
//  DHKApi
//
//  Created by Ryan Wachowski on 8/6/18.
//  Copyright © 2018 Duet Health. All rights reserved.
//

import Foundation

public extension KeyedDecodingContainer {

    public func decode(_ type: [String: Any].Type, forKey key: Key, strategy: DynamicKeyStrategy = .camelToSnakeCase) throws -> [String: Any] {
        let container = try nestedContainer(keyedBy: DynamicCodingKeys.self, forKey: key)
        return container.decode(type, strategy: strategy)
    }

    public func decode(_ type: [Any].Type, forKey key: Key, strategy: DynamicKeyStrategy = .camelToSnakeCase) throws -> [Any] {
        var container = try nestedUnkeyedContainer(forKey: key)
        return try container.decode(type, strategy: strategy)
    }

    public func decodeIfPresent(_ type: [String: Any].Type, forKey key: Key, strategy: DynamicKeyStrategy = .camelToSnakeCase) throws -> [String: Any]? {
        guard contains(key) else { return nil }
        if try decodeNil(forKey: key) { return nil }
        return try decode(type, forKey: key, strategy: strategy)
    }

    public func decodeIfPresent(_ type: [Any].Type, forKey key: Key, strategy: DynamicKeyStrategy = .camelToSnakeCase) throws -> [Any]? {
        if !contains(key), try decodeNil(forKey: key) { return nil }
        return try decode(type, forKey: key, strategy: strategy)
    }

    public func decode(_ type: [String: Any].Type, strategy: DynamicKeyStrategy = .camelToSnakeCase) -> [String: Any] {
        var result = [String: Any]()
        allKeys.forEach {
            let target = strategy.modify(key: $0).stringValue
            if let bool = try? decode(Bool.self, forKey: $0) { result[target] = bool }
            else if let string = try? decode(String.self, forKey: $0) { result[target] = string }
            else if let int = try? decode(Int.self, forKey: $0) { result[target] = int }
            else if let double = try? decode(Double.self, forKey: $0) { result[target] = double }
            else if let dictionary = try? decode([String: Any].self, forKey: $0, strategy: strategy) { result[target] = dictionary }
            else if let array = try? decode([Any].self, forKey: $0, strategy: strategy) { result[target] = array }
        }
        return result
    }

}
