//
//  JSONWrapper.swift
//  CNS
//
//  Created by ライアン on 10/29/18.
//  Copyright © 2018 Duet Health. All rights reserved.
//

import Foundation

struct JSONWrapper<Inner: Decodable>: Decodable {
    
    private var matchContainer: MatchContainer<Inner>
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        matchContainer = MatchContainer<Inner>()
        let shouldIterateAll = (matchContainer as? Matching)?.shouldIterateAll ?? false
        
        for key in container.allKeys {
            if let value = try? container.decode(Inner.self, forKey: key) {
                matchContainer.insert(value, forKey: key.stringValue)
            }
            if shouldIterateAll { continue }
            return
        }
        guard matchContainer.isEmpty else { return }
        let context = DecodingError.Context(codingPath: container.codingPath, debugDescription: "A nested value of type \(Inner.self) was not found.")
        throw DecodingError.valueNotFound(Inner.self, context)
    }
    
    func value(forKey key: String) throws -> Inner {
        if let value = matchContainer.value(forKey: key) { return value }
        let context = DecodingError.Context(codingPath: [], debugDescription: "Tried to find data nested under \(key), but found it under the following keys: \(matchContainer.discoveredKeys)")
        throw DecodingError.keyNotFound(DynamicCodingKeys(stringValue: key)!, context)
    }
    
}

fileprivate struct MatchContainer<Contained> {
    
    private var allMatches = [String: Contained]()
    
    var discoveredKeys: [String] {
        return Array(allMatches.keys)
    }
    
    var isEmpty: Bool {
        return allMatches.isEmpty
    }
    
    mutating func insert(_ value: Contained, forKey key: String) {
        allMatches[key] = value
    }
    
    func value(forKey key: String) -> Contained? {
        return allMatches[key]
    }
    
}

protocol Matching {
    
    var shouldIterateAll: Bool { get }
    
}

extension MatchContainer: Matching where Contained: Collection {
    
    var shouldIterateAll: Bool {
        return true
    }
    
}
