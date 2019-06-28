import Foundation

public class XMLDecoder {

    public enum KeyDecodingStrategy {
        public enum Casing: Equatable { case lower, upper }

        private static let snakeCaseRegex = try! NSRegularExpression(pattern: "([a-z0-9])([A-Z])", options: [])

        case useDefaultKeys
        case convertFromPascalCase
        case convertFromSnakeCase
        case convertFromCasing(Casing)

        func compare(key: CodingKey, to raw: String) -> Bool {
            switch self {
            case .useDefaultKeys:
                return raw == key.stringValue
            case .convertFromPascalCase:
                return raw == key.stringValue.prefix(1).capitalized + key.stringValue.dropFirst()
            case .convertFromSnakeCase:
                return raw == type(of: self).snakeCaseRegex.stringByReplacingMatches(in: key.stringValue, options: [], range: NSRange(location: 0, length: key.stringValue.count), withTemplate: "$1_$2").lowercased()
            case .convertFromCasing(.lower):
                return raw == key.stringValue.lowercased()
            case .convertFromCasing(.upper):
                return raw == key.stringValue.uppercased()
            }
        }
    }

    var objectDecodingStrategy: KeyDecodingStrategy = .useDefaultKeys
    var keyDecodingStrategy: KeyDecodingStrategy = .useDefaultKeys

    public init() {

    }

    public func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let strategy = self.keyDecodingStrategy
        return try T.init(from: XMLDeserializer(data: data, keyMatching: strategy.compare))
    }

}

extension XMLDecoder: RequestDecoding {

    public var acceptType: MIMEType {
        return .textXML()
    }

}
