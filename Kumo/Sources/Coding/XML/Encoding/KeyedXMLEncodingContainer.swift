import Foundation

struct KeyedXMLEncodingContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {

    var codingPath: [CodingKey] = []

    private let context: XMLNodeWritingContext
    private let strategies: XMLEncodingStrategies

    init(context: XMLNodeWritingContext, strategies: XMLEncodingStrategies) {
        self.context = context
        self.strategies = strategies
    }

    mutating func encodeNil(forKey key: Key) throws {
        var node = strategies.createNode(under: key)
        strategies.encodeNil(in: &node)
        try context.addLeaf(node: node)
    }

    mutating func encode(_ value: Bool, forKey key: Key) throws {
        try commonEncode(String(describing: value), forKey: key)
    }

    mutating func encode(_ value: String, forKey key: Key) throws {
        try commonEncode(value, forKey: key)
    }

    mutating func encode(_ value: Double, forKey key: Key) throws {
        try commonEncode(String(describing: value), forKey: key)
    }

    mutating func encode(_ value: Float, forKey key: Key) throws {
        try commonEncode(String(describing: value), forKey: key)
    }

    mutating func encode(_ value: Int, forKey key: Key) throws {
        try commonEncode(String(describing: value), forKey: key)
    }

    mutating func encode(_ value: Int8, forKey key: Key) throws {
        try commonEncode(String(describing: value), forKey: key)
    }

    mutating func encode(_ value: Int16, forKey key: Key) throws {
        try commonEncode(String(describing: value), forKey: key)
    }

    mutating func encode(_ value: Int32, forKey key: Key) throws {
        try commonEncode(String(describing: value), forKey: key)
    }

    mutating func encode(_ value: Int64, forKey key: Key) throws {
        try commonEncode(String(describing: value), forKey: key)
    }

    mutating func encode(_ value: UInt, forKey key: Key) throws {
        try commonEncode(String(describing: value), forKey: key)
    }

    mutating func encode(_ value: UInt8, forKey key: Key) throws {
        try commonEncode(String(describing: value), forKey: key)
    }

    mutating func encode(_ value: UInt16, forKey key: Key) throws {
        try commonEncode(String(describing: value), forKey: key)
    }

    mutating func encode(_ value: UInt32, forKey key: Key) throws {
        try commonEncode(String(describing: value), forKey: key)
    }

    mutating func encode(_ value: UInt64, forKey key: Key) throws {
        try commonEncode(String(describing: value), forKey: key)
    }

    mutating func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        if (value is Bool) { return try encode(value as! Bool, forKey: key) }
        if (value is String) { return try encode(value as! String, forKey: key) }
        if (value is Double) { return try encode(value as! Double, forKey: key) }
        if (value is Float) { return try encode(value as! Float, forKey: key) }
        if (value is Int) { return try encode(value as! Int, forKey: key) }
        if (value is Int16) { return try encode(value as! Int16, forKey: key) }
        if (value is Int32) { return try encode(value as! Int32, forKey: key) }
        if (value is Int64) { return try encode(value as! Int64, forKey: key) }
        if (value is UInt) { return try encode(value as! UInt, forKey: key) }
        if (value is UInt16) { return try encode(value as! UInt16, forKey: key) }
        if (value is UInt32) { return try encode(value as! UInt32, forKey: key) }
        if (value is UInt64) { return try encode(value as! UInt64, forKey: key) }
        let constructor = XMLConstructor(context: XMLNodeWritingContext(node: strategies.createNode(under: key)), strategies: strategies.strategies(for: key))
        try value.encode(to: constructor)
        try context.addLeaf(node: constructor.context.consumeNode())
    }

    mutating func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
        context.addNested(node: strategies.createNode(under: key))
        return KeyedEncodingContainer(KeyedXMLEncodingContainer<NestedKey>(context: context, strategies: strategies.strategies(for: key)))
    }

    mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        context.addNested(node: strategies.createNode(under: key))
        return UnkeyedXMLEncodingContainer(context: context, strategies: strategies)
    }

    mutating func superEncoder() -> Encoder {
        fatalError("""
        If you're reading this, you must need it.
        I didn't need it, so I didn't implement it.
        I don't understand XML.
        Please forgive me and implement this.
        """)
    }

    mutating func superEncoder(forKey key: Key) -> Encoder {
        fatalError("""
        If you're reading this, you must need it.
        I didn't need it, so I didn't implement it.
        I don't understand XML.
        Please forgive me and implement this.
        """)
    }

    private mutating func commonEncode(_ value: String, forKey key: Key) throws {
        var node = strategies.createNode(under: key)
        node.child = .text(value)
        try context.addLeaf(node: node)
    }

}
