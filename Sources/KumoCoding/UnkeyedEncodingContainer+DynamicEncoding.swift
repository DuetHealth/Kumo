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
            } else if let encodable = ($0 as? NSObject).flatMap(bridgeFromNSObject) {
                try encode(encodable)
            } else {
                let codingPath = self.codingPath
                let context = EncodingError.Context(codingPath: codingPath, debugDescription: "The value at index \(count) is not encodable.")
                throw EncodingError.invalidValue($0, context)
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
