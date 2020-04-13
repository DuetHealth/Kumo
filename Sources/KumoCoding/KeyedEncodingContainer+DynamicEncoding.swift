import Foundation

public extension KeyedEncodingContainer {

    mutating func encode(_ value: [String: Any], forKey key: Key, strategy: DynamicKeyStrategy = .default) throws {
        var container = nestedContainer(keyedBy: DynamicCodingKeys.self, forKey: key)
        try container.encode(value, strategy: strategy)
    }

    mutating func encodeIfPresent(_ value: [String: Any]?, forKey key: Key, strategy: DynamicKeyStrategy = .default) throws {
        guard let value = value else {
            try encodeNil(forKey: key)
            return
        }
        try encode(value, forKey: key, strategy: strategy)
    }

    mutating func encode(_ value: [Any], forKey key: Key, strategy: DynamicKeyStrategy = .default) throws {
        var container = nestedUnkeyedContainer(forKey: key)
        try container.encode(value, strategy: strategy)
    }

    mutating func encodeIfPresent(_ value: [Any]?, forKey key: Key, strategy: DynamicKeyStrategy = .default) throws {
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
            } else if let encodable = ($0.value as? NSObject).flatMap(bridgeFromNSObject) {
                try encode(encodable, forKey: modifiedKey)
            } else {
                let codingPath = self.codingPath + [modifiedKey]
                let context = EncodingError.Context(codingPath: codingPath, debugDescription: "The value for the given key is not encodable.")
                throw EncodingError.invalidValue($0.value, context)
            }
        }
    }

    private func bridgeFromNSObject(_ object: NSObject) -> ErasedEncodable? {
        switch object {
        case let string as NSString:
            return ErasedEncodable(string as String)
        case let number as NSNumber where CFNumberGetType(number) == .charType:
            return ErasedEncodable(number.boolValue)
        case let number as NSNumber where CFNumberGetType(number).isInteger:
            return ErasedEncodable(number.intValue)
        case let number as NSNumber:
            return ErasedEncodable(number.doubleValue)
        default: return nil
        }
    }

}

// NSNumber can be initialized with a Boolean, integer, or floating-point value. These are also the only values
// that truly matter for JSON.
extension CFNumberType {

    var isInteger: Bool {
        return Set([CFNumberType.sInt8Type, .sInt16Type, .sInt32Type, .sInt64Type, .shortType, .intType, .longType, .longLongType, .cfIndexType, .nsIntegerType]).contains(self)
    }

}
