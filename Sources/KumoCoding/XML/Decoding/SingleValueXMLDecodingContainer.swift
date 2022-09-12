import Foundation

struct SingleValueXMLDecodingContainer: SingleValueDecodingContainer {

    var codingPath: [CodingKey] = []

    private let node: XMLNode
    private let keyMatching: (CodingKey, String) -> Bool

    init(_ node: XMLNode, keyMatching: @escaping (CodingKey, String) -> Bool) {
        self.node = node
        self.keyMatching = keyMatching
    }

    func decodeNil() -> Bool {
        return node.isEmpty
    }

    func decode(_ type: Bool.Type) throws -> Bool {
        return try commonDecode(Bool.init)
    }

    func decode(_ type: String.Type) throws -> String {
        return try commonDecode(String.init(stringLiteral:))
    }

    func decode(_ type: Double.Type) throws -> Double {
        return try commonDecode(Double.init)
    }

    func decode(_ type: Float.Type) throws -> Float {
        return try commonDecode(Float.init)
    }

    func decode(_ type: Int.Type) throws -> Int {
        return try commonDecode(Int.init)
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
        return try commonDecode(Int8.init)
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
        return try commonDecode(Int16.init)
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
        return try commonDecode(Int32.init)
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
        return try commonDecode(Int64.init)
    }

    func decode(_ type: UInt.Type) throws -> UInt {
        return try commonDecode(UInt.init)
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
        return try commonDecode(UInt8.init)
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
        return try commonDecode(UInt16.init)
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
        return try commonDecode(UInt32.init)
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
        return try commonDecode(UInt64.init)
    }

    func decode<T: Decodable>(_ type: T.Type) throws -> T {
        if type == Bool.self { return try decode(Bool.self) as! T }
        if type == String.self { return try decode(String.self) as! T }
        if type == Double.self { return try decode(Double.self) as! T }
        if type == Float.self { return try decode(Float.self) as! T }
        if type == Int.self { return try decode(Int.self) as! T }
        if type == Int8.self { return try decode(Int8.self) as! T }
        if type == Int16.self { return try decode(Int8.self) as! T }
        if type == Int32.self { return try decode(Int8.self) as! T }
        if type == Int64.self { return try decode(Int8.self) as! T }
        if type == UInt.self { return try decode(Int.self) as! T }
        if type == UInt8.self { return try decode(Int8.self) as! T }
        if type == UInt16.self { return try decode(Int8.self) as! T }
        if type == UInt32.self { return try decode(Int8.self) as! T }
        if type == UInt64.self { return try decode(Int8.self) as! T }
        return try T.init(from: XMLDeserializer(node: node, keyMatching: keyMatching))
    }

    private func commonDecode<T>(_ initializer: (String) -> T?) throws -> T {
        switch node.child {
        case .nodes: throw DecodingError.typeMismatch(T.self, DecodingError.Context(codingPath: codingPath, debugDescription: "Could not decode a value for node \"\(node.name)\" which has child nodes."))
        case .text(let string):
            return try initializer(string) ?? throwError(DecodingError.typeMismatch(T.self, DecodingError.Context(codingPath: codingPath, debugDescription: "Could not decode value \"\(string)\" under node \"\(node.name)\" as type \(T.self).")))
        }
    }

}
