//
//  DynamicCoding.swift
//  DHKApi
//
//  Created by Ryan Wachowski on 8/6/18.
//  Copyright © 2018 Duet Health. All rights reserved.
//

import Foundation

public struct DynamicCodingKeys: CodingKey {

    public var stringValue: String
    public var intValue: Int?

    public init?(stringValue: String) {
        self.stringValue = stringValue
        intValue = nil
    }

    public init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
        self.intValue = intValue
    }

}

public enum DynamicKeyStrategy {

    /// The key retains its interpreted value.
    ///
    /// You may use this case if you wish to retain the object's dynamic keys, such as when re-encoding
    /// an untyped dictionary.
    case `default`

    /// The key is transformed from an interpreted camel case to snake case.
    ///
    /// You may use this case if a super decoder or encoder will attempt to convert snake case keys
    /// to a camel case key.
    case camelToSnakeCase

    /// The key is transformed from an interpreted snake case to camel case.
    ///
    /// You may use this case if a super decoder or encoder will attempt to convert camel case keys
    /// to a snake case key.
    case snakeToCamelCase

    /// Transforms a key using the represented strategy.
    func modify(key: CodingKey) -> DynamicCodingKeys {
        switch self {
        case .default: return DynamicCodingKeys(stringValue: key.stringValue)!
        case .camelToSnakeCase: return DynamicCodingKeys(stringValue: convertCamelToSnakeCase(key: key.stringValue))!
        case .snakeToCamelCase: return DynamicCodingKeys(stringValue: convertSnakeToCamelCase(key: key.stringValue))!
        }
    }

}

fileprivate func convertCamelToSnakeCase(key: String) -> String {
    return key.reduce("") { mapped, character in
        let unicodeRepresentation = character.unicodeScalars
        guard unicodeRepresentation.count == 1 else { return mapped + "\(character)" }
        let scalar = unicodeRepresentation.first!
        let next = CharacterSet.uppercaseLetters.contains(scalar) ? "_\(String(scalar).lowercased())" : "\(character)"
        return mapped + next
    }
}

fileprivate func convertSnakeToCamelCase(key: String) -> String {
    let segments = key.split(separator: "_")
    guard segments.count > 0 else { return "" }
    return String(segments.first!) + segments.dropFirst().reduce("") { aggregate, next in
        aggregate + next.capitalized
    }
}

