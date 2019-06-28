import Foundation

public extension KeyedEncodingContainer {

    public mutating func encode(_ value: [String: Any], forKey key: Key, strategy: DynamicKeyStrategy = .default) throws {
        var container = nestedContainer(keyedBy: DynamicCodingKeys.self, forKey: key)
        try container.encode(value, strategy: strategy)
    }

    public mutating func encodeIfPresent(_ value: [String: Any]?, forKey key: Key, strategy: DynamicKeyStrategy = .default) throws {
        guard let value = value else {
            try encodeNil(forKey: key)
            return
        }
        try encode(value, forKey: key, strategy: strategy)
    }

    public mutating func encode(_ value: [Any], forKey key: Key, strategy: DynamicKeyStrategy = .default) throws {
        var container = nestedUnkeyedContainer(forKey: key)
        try container.encode(value, strategy: strategy)
    }

    public mutating func encodeIfPresent(_ value: [Any]?, forKey key: Key, strategy: DynamicKeyStrategy = .default) throws {
        guard let value = value else {
            try encodeNil(forKey: key)
            return
        }
        try encode(value, forKey: key, strategy: strategy)
    }

}

extension KeyedEncodingContainer where Key == DynamicCodingKeys {

    public mutating func encode(_ value: [String: Any], strategy: DynamicKeyStrategy = .default) throws {
        try value.forEach {
            let modifiedKey = strategy.modify(key: DynamicCodingKeys(stringValue: $0.key)!)
            if let dictionary = $0.value as? [String: Any] {
                try encode(dictionary, forKey: modifiedKey, strategy: strategy)
            } else if let array = $0.value as? [Any] {
                try encode(array, forKey: modifiedKey, strategy: strategy)
            } else if let encodable = $0.value as? Encodable {
                try encode(ErasedEncodable(encodable), forKey: modifiedKey)
            } else {
                let codingPath = self.codingPath + [modifiedKey]
                let context = EncodingError.Context(codingPath: codingPath, debugDescription: "The value for the given key is not encodable.")
                throw EncodingError.invalidValue($0.value, context)
            }
        }
    }

}
