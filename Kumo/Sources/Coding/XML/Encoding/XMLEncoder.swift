import Foundation

public class XMLEncoder {

    public enum KeyEncodingStrategy {
        public enum Casing: Equatable { case lower, upper }

        private static let snakeCaseRegex = try! NSRegularExpression(pattern: "([a-z0-9])([A-Z])", options: [])

        case useDefaultKeys
        case convertToPascalCase
        case convertToSnakeCase
        case convertToCasing(Casing)

        func convert(key: CodingKey) -> String {
            switch self {
            case .useDefaultKeys:
                return key.stringValue
            case .convertToPascalCase:
                return key.stringValue.prefix(1).capitalized + key.stringValue.dropFirst()
            case .convertToSnakeCase:
                return type(of: self).snakeCaseRegex.stringByReplacingMatches(in: key.stringValue, options: [], range: NSRange(location: 0, length: key.stringValue.count), withTemplate: "$1_$2").lowercased()
            case .convertToCasing(.lower):
                return key.stringValue.lowercased()
            case .convertToCasing(.upper):
                return key.stringValue.uppercased()
            }
        }
    }

    public enum NilEncodingStrategy {
        case useNilAttribute
        case leaveEmpty
    }

    public var keyEncodingStrategy = KeyEncodingStrategy.useDefaultKeys
    public var nilEncodingStrategy = NilEncodingStrategy.useNilAttribute
    public var userInfo = [CodingUserInfoKey: Any]()

    public init() { }

    public func encode<T: Encodable>(_ value: T) throws -> Data {
        let constructor = XMLConstructor(strategies: XMLEncodingStrategies(keyEncodingStrategy: keyEncodingStrategy, nilEncoding: nilEncodingStrategy, userInfo: userInfo))
        try value.encode(to: constructor)
        return try constructor.context.consumeContext().data(using: .utf8) ?? throwError(NSError())
    }
    
}

extension XMLEncoder: RequestEncoding {

    public var contentType: MIMEType {
        return .textXML()
    }

}
