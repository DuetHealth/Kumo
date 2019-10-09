import Foundation

struct KeyedXMLDecodingContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {

    private let node: XMLNode
    private let keyMatching: (CodingKey, String) -> Bool

    var codingPath: [CodingKey] = []
    var allKeys: [Key]

    init(_ node: XMLNode, keyMatching: @escaping (CodingKey, String) -> Bool) {
        self.node = node
        self.keyMatching = keyMatching
        switch node.child {
        case .nodes(let nodes): allKeys = nodes.compactMap { Key(stringValue: $0.name) }
        default: allKeys = []
        }
    }

    func contains(_ key: Key) -> Bool {
        return allKeys.contains { $0.stringValue == key.stringValue }
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        guard let child = node.find(named: key.stringValue) else { return true }
        return SingleValueXMLDecodingContainer(child, keyMatching: keyMatching).decodeNil()
    }

    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        return try singleValueDecode(under: key)
    }

    func decode(_ type: String.Type, forKey key: Key) throws -> String {
        return try singleValueDecode(under: key)
    }

    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        return try singleValueDecode(under: key)
    }

    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        return try singleValueDecode(under: key)
    }

    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        return try singleValueDecode(under: key)
    }

    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        return try singleValueDecode(under: key)
    }

    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        return try singleValueDecode(under: key)
    }

    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        return try singleValueDecode(under: key)
    }

    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        return try singleValueDecode(under: key)
    }

    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        return try singleValueDecode(under: key)
    }

    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        return try singleValueDecode(under: key)
    }

    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        return try singleValueDecode(under: key)
    }

    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        return try singleValueDecode(under: key)
    }

    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        return try singleValueDecode(under: key)
    }

    func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
        return try node.find(key: key, with: keyMatching)
            .map { try T.init(from: XMLDeserializer(node: $0, keyMatching: keyMatching)) }
            ?? throwError(DecodingError.keyNotFound(key, DecodingError.Context(codingPath: [], debugDescription: "Could not find key \(key) nested under node \(node.name).")))
    }

    func nestedContainer<NestedKey: CodingKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> {
        return try node.find(key: key, with: keyMatching)
            .map { KeyedDecodingContainer(KeyedXMLDecodingContainer<NestedKey>($0, keyMatching: keyMatching)) }
            ?? throwError(DecodingError.keyNotFound(key, DecodingError.Context(codingPath: [], debugDescription: "Could not find key \(key) nested under node \(node.name).")))
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        return try node.find(key: key, with: keyMatching)
            .map { UnkeyedXMLDecodingContainer(root: $0, keyMatching: keyMatching) }
            ?? throwError(DecodingError.keyNotFound(key, DecodingError.Context(codingPath: [], debugDescription: "Could not find key \(key) nested under node \(node.name).")))
    }

    func superDecoder() throws -> Decoder {
        // NOTE: for subclassing?
        fatalError("""
        If you're reading this, you must need it.
        I didn't need it, so I didn't implement it.
        I don't understand XML.
        Please forgive me and implement this.
        """)
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        // NOTE: for subclassing?
        fatalError("""
        If you're reading this, you must need it.
        I didn't need it, so I didn't implement it.
        I don't understand XML.
        Please forgive me and implement this.
        """)
    }

    private func singleValueDecode<T: Decodable>(under key: Key) throws -> T {
        return try node.find(key: key, with: keyMatching)
            .map { SingleValueXMLDecodingContainer($0, keyMatching: keyMatching) }?
            .decode(T.self)
            ?? throwError(DecodingError.keyNotFound(key, DecodingError.Context(codingPath: [], debugDescription: "Could not find key \(key) nested under node \(node.name).")))
    }

}
