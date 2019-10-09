import Foundation

struct UnkeyedXMLEncodingContainer: UnkeyedEncodingContainer {

    var count: Int {
        return contents.count
    }

    var codingPath: [CodingKey] = []

    private let context: XMLNodeWritingContext
    private let strategies: XMLEncodingStrategies
    private var contents = [Any]()

    init(context: XMLNodeWritingContext, strategies: XMLEncodingStrategies) {
        self.context = context
        self.strategies = strategies
    }

    mutating func encodeNil() throws {
        var node = strategies.createNode(listedUnder: context.root)
        strategies.encodeNil(in: &node)
        try context.addLeaf(node: node)
    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        context.addNested(node: strategies.createNode(listedUnder: context.root))
        return KeyedEncodingContainer(KeyedXMLEncodingContainer<NestedKey>(context: context, strategies: strategies))
    }

    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        context.addNested(node: strategies.createNode(listedUnder: context.root))
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

    mutating func encode(_ value: Bool) throws {
        try commonEncode(String(describing: value))
    }

    mutating func encode(_ value: String) throws {
        try commonEncode(String(describing: value))
    }

    mutating func encode(_ value: Double) throws {
        try commonEncode(String(describing: value))
    }

    mutating func encode(_ value: Float) throws {
        try commonEncode(String(describing: value))
    }

    mutating func encode(_ value: Int) throws {
        try commonEncode(String(describing: value))
    }

    mutating func encode(_ value: Int8) throws {
        try commonEncode(String(describing: value))
    }

    mutating func encode(_ value: Int16) throws {
        try commonEncode(String(describing: value))
    }

    mutating func encode(_ value: Int32) throws {
        try commonEncode(String(describing: value))
    }

    mutating func encode(_ value: Int64) throws {
        try commonEncode(String(describing: value))
    }

    mutating func encode(_ value: UInt) throws {
        try commonEncode(String(describing: value))
    }

    mutating func encode(_ value: UInt8) throws {
        try commonEncode(String(describing: value))
    }

    mutating func encode(_ value: UInt16) throws {
        try commonEncode(String(describing: value))
    }

    mutating func encode(_ value: UInt32) throws {
        try commonEncode(String(describing: value))
    }

    mutating func encode(_ value: UInt64) throws {
        try commonEncode(String(describing: value))
    }

    mutating func encode<T>(_ value: T) throws where T : Encodable {
        if (value is Bool) { return try encode(value as! Bool) }
        if (value is String) { return try encode(value as! String) }
        if (value is Double) { return try encode(value as! Double) }
        if (value is Float) { return try encode(value as! Float) }
        if (value is Int) { return try encode(value as! Int) }
        if (value is Int16) { return try encode(value as! Int16) }
        if (value is Int32) { return try encode(value as! Int32) }
        if (value is Int64) { return try encode(value as! Int64) }
        if (value is UInt) { return try encode(value as! UInt) }
        if (value is UInt16) { return try encode(value as! UInt16) }
        if (value is UInt32) { return try encode(value as! UInt32) }
        if (value is UInt64) { return try encode(value as! UInt64) }

        // Technically the strategy could/should change but we're ignoring most of the things strategies should be doing when encoding lists anyway.
        let constructor = XMLConstructor(context: XMLNodeWritingContext(node: strategies.createNode(listedUnder: context.root)), strategies: strategies)
        try value.encode(to: constructor)
        try context.addLeaf(node: constructor.context.consumeNode())
    }

    private mutating func commonEncode(_ value: String) throws {
        var node = strategies.createNode(listedUnder: context.root)
        node.child = .text(value)
        try context.addLeaf(node: node)
    }

}
