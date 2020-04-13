import Foundation

struct UnkeyedXMLDecodingContainer: UnkeyedDecodingContainer {

    var codingPath = [CodingKey]()

    var count: Int? {
        switch root.child {
        case .nodes(let nodes):
            return nodes.count
        case .text:
            print("Kumo:UnkeyedXMLDecodingContainer:count - As far as I can tell this should never happen. If it has happened please fix it.")
            return nil
        }
    }
    var isAtEnd: Bool { return currentIndex >= count ?? 0 }
    var currentIndex: Int = 0

    private var container = [Any]()
    private let root: XMLNode
    private let keyMatching: (CodingKey, String) -> Bool

    mutating func currentNode() -> XMLNode {
        switch root.child {
        case .nodes(let nodes):
            let node = nodes[currentIndex]
            currentIndex += 1
            return node
        case .text:
            fatalError("Kumo:UnkeyedXMLDecodingContainer:currentNode - As far as I can tell this should never happen. If it has happened please fix it.")
        }
    }

    init(root: XMLNode, keyMatching: @escaping (CodingKey, String) -> Bool) {
        self.root = root
        self.keyMatching = keyMatching
    }

    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        return KeyedDecodingContainer(KeyedXMLDecodingContainer<NestedKey>(currentNode(), keyMatching: keyMatching))
    }

    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        return UnkeyedXMLDecodingContainer(root: currentNode(), keyMatching: keyMatching)
    }

    mutating func superDecoder() throws -> Decoder {
        throw NSError(domain: "com.duet.kumo.unkeyedxmldecodingcontainer", code: 1, userInfo: ["message": "superDecoder not implemented. Honestly stop using classes."])
    }

    func decodeNil() -> Bool {
        return root.isEmpty
    }

    mutating func decode(_ type: Bool.Type) throws -> Bool {
        return try singleValueDecode()
    }

    mutating func decode(_ type: String.Type) throws -> String {
        return try singleValueDecode()
    }

    mutating func decode(_ type: Double.Type) throws -> Double {
        return try singleValueDecode()
    }

    mutating func decode(_ type: Float.Type) throws -> Float {
        return try singleValueDecode()
    }

    mutating func decode(_ type: Int.Type) throws -> Int {
        return try singleValueDecode()
    }

    mutating func decode(_ type: Int8.Type) throws -> Int8 {
        return try singleValueDecode()
    }

    mutating func decode(_ type: Int16.Type) throws -> Int16 {
        return try singleValueDecode()
    }

    mutating func decode(_ type: Int32.Type) throws -> Int32 {
        return try singleValueDecode()
    }

    mutating func decode(_ type: Int64.Type) throws -> Int64 {
        return try singleValueDecode()
    }

    mutating func decode(_ type: UInt.Type) throws -> UInt {
        return try singleValueDecode()
    }

    mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
        return try singleValueDecode()
    }

    mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
        return try singleValueDecode()
    }

    mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        return try singleValueDecode()
    }

    mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        return try singleValueDecode()
    }

    mutating func decode<T: Decodable>(_ type: T.Type) throws -> T {
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
        return try T.init(from: XMLDeserializer(node: currentNode(), keyMatching: keyMatching))
    }

    private mutating func singleValueDecode<T: Decodable>() throws -> T {
        return try SingleValueXMLDecodingContainer(currentNode(), keyMatching: keyMatching).decode(T.self)
    }

}
