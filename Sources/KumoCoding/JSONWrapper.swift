import Foundation

public struct JSONWrapper<Inner: Decodable>: Decodable {
    
    private var matchContainer: MatchContainer<Inner>
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        matchContainer = MatchContainer<Inner>()
        let shouldContinueAfterMatch = (matchContainer as? AmbiguousMatching)?.shouldContinueAfterMatch ?? true
        
        for key in container.allKeys {
            guard let value = try? container.decode(Inner.self, forKey: key) else { continue }
            matchContainer.insert(value, forKey: key.stringValue)
            if shouldContinueAfterMatch { continue }
            return
        }
        
        guard matchContainer.isEmpty else { return }
        let context = DecodingError.Context(codingPath: container.codingPath, debugDescription: "A nested value of type \(Inner.self) was not found.")
        throw DecodingError.valueNotFound(Inner.self, context)
    }
    
    public func value(forKey key: String) throws -> Inner {
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

protocol AmbiguousMatching {
    
    var shouldContinueAfterMatch: Bool { get }
    
}

extension MatchContainer: AmbiguousMatching where Contained: Collection {
    
    var shouldContinueAfterMatch: Bool {
        return true
    }
    
}
