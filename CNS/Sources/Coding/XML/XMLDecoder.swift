//
//  SOAPDecoder.swift
//  CNS
//
//  Created by ライアン on 5/20/19.
//  Copyright © 2019 Duet Health. All rights reserved.
//

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
        return try T.init(from: XMLProcessor(data: data, keyMatching: strategy.compare))
    }

}

extension XMLDecoder: RequestDecoding {

    public var acceptType: MIMEType {
        return .textXML()
    }

}

struct XMLNode {

    enum Child {
        case nodes([XMLNode])
        case text(String)
    }

    static var root: XMLNode {
        return XMLNode()
    }

    var name: String
    var attributes: [String: String]
    var child: Child

    let isRoot: Bool

    init(name: String, attributes: [String: String], child: Child) {
        self.name = name
        self.attributes = attributes
        self.child = child
        isRoot = false
    }

    private init() {
        name = ""
        attributes = [:]
        child = .nodes([])
        isRoot = true
    }

    var isEmpty: Bool {
        switch child {
        case .nodes(let nodes): return nodes.isEmpty
        case .text(let text): return text.isEmpty
        }
    }

    func find<Key: CodingKey>(key: Key, with matcher: (Key, String) -> Bool) -> XMLNode? {
        guard case .nodes(let nodes) = child else { return nil }
        return nodes.first { matcher(key, $0.name) }
    }

    func find(named name: String) -> XMLNode? {
        guard case .nodes(let nodes) = child else { return nil }
        return nodes.first { $0.name == name }
    }

}

fileprivate class XMLProcessor: NSObject, Decoder, XMLParserDelegate {

    private let keyMatching: (CodingKey, String) -> Bool

    private(set) var codingPath: [CodingKey] = []
    private(set) var userInfo: [CodingUserInfoKey : Any] = [:]
    private var parser: XMLParser!
    private var root: XMLNode!
    private var parsingError: Error?
    private var stack = StackDecorator<XMLNode>()

    init(data: Data, keyMatching: @escaping (CodingKey, String) -> Bool) throws {
        self.keyMatching = keyMatching
        parser = XMLParser(data: data)
        parser.shouldProcessNamespaces = true
        parser.shouldReportNamespacePrefixes = true
        super.init()
        parser.delegate = self
        guard parser.parse() else { throw parser.parserError ?? NSError() }
    }

    init(node: XMLNode, keyMatching: @escaping (CodingKey, String) -> Bool) {
        self.keyMatching = keyMatching
        root = node
    }

    func container<Key: CodingKey>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        return KeyedDecodingContainer(KeyedXMLNodeContainer<Key>(root, keyMatching: keyMatching))
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        throw NSError()
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return SingleValueXMLNodeContainer(root, keyMatching: keyMatching)
    }

    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        fatalError("""
        If you're reading this, you must need it.
        I didn't need it, so I didn't implement it.
        I don't understand XML.
        Please forgive me and implement this.
        """)
    }

    func parserDidStartDocument(_ parser: XMLParser) {
        stack.push(.root)
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        stack.push(XMLNode(name: elementName, attributes: attributeDict, child: .nodes([])))
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        // NOTE: Is this actually an error if false?
        guard stack.peek?.name == elementName else { return }
        let finished = stack.pop()
        stack.update {
            switch $0.child {
            case .nodes(let nodes): $0.child = .nodes(nodes + [finished])
            case .text: fatalError("TODO: this is an XML error that should be thrown.")
            }
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        // NOTE: This _should_ pass most well-formed and not-shitty APIs, but if only whitespace is
        // valid for the textual contents of a node then this will trim it and make the node leaf.
        guard stack.isNotEmpty, string.trimmingCharacters(in: .whitespacesAndNewlines).isNotEmpty else { return }
        stack.update {
            switch $0.child {
            case .nodes(let nodes) where nodes.isNotEmpty: fatalError("TODO: this is an XML error that should be thrown.")
            default: $0.child = .text(string)
            }
        }
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        guard stack.isNotEmpty else { fatalError("Internal error: root node not found.") }
        root = stack.pop()
    }

}

struct StackDecorator<Element> {

    var array: [Element]

    var isEmpty: Bool {
        return array.isEmpty
    }

    var isNotEmpty: Bool {
        return array.isNotEmpty
    }

    var peek: Element? {
        return array.last
    }

    init(_ array: [Element] = []) {
        self.array = array
    }

    mutating func push(_ element: Element) {
        array.append(element)
    }

    mutating func pop() -> Element {
        return array.removeLast()
    }

    mutating func update(with closure: (inout Element) throws -> ()) rethrows {
        try closure(&array[array.count - 1])
    }

}

struct KeyedXMLNodeContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {

    private let node: XMLNode
    private let keyMatching: (CodingKey, String) -> Bool

    var codingPath: [CodingKey] = []
    var allKeys: [Key]

    fileprivate init(_ node: XMLNode, keyMatching: @escaping (CodingKey, String) -> Bool) {
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
        return SingleValueXMLNodeContainer(child, keyMatching: keyMatching).decodeNil()
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
            .map { try T.init(from: XMLProcessor(node: $0, keyMatching: keyMatching)) }
            ?? throwError(NSError())
    }

    func nestedContainer<NestedKey: CodingKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> {
        return try node.find(key: key, with: keyMatching)
            .map { KeyedDecodingContainer(KeyedXMLNodeContainer<NestedKey>($0, keyMatching: keyMatching)) }
            ?? throwError(NSError())
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        throw NSError()
    }

    func superDecoder() throws -> Decoder {
        fatalError("""
        If you're reading this, you must need it.
        I didn't need it, so I didn't implement it.
        I don't understand XML.
        Please forgive me and implement this.
        """)
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        fatalError("""
        If you're reading this, you must need it.
        I didn't need it, so I didn't implement it.
        I don't understand XML.
        Please forgive me and implement this.
        """)
    }

    private func singleValueDecode<T: Decodable>(under key: Key) throws -> T {
        return try node.find(key: key, with: keyMatching)
            .map { SingleValueXMLNodeContainer($0, keyMatching: keyMatching) }?
            .decode(T.self)
            ?? throwError(NSError())
    }

}

struct SingleValueXMLNodeContainer: SingleValueDecodingContainer {

    var codingPath: [CodingKey] = []

    private let node: XMLNode
    private let keyMatching: (CodingKey, String) -> Bool

    fileprivate init(_ node: XMLNode, keyMatching: @escaping (CodingKey, String) -> Bool) {
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
        return try commonDecode(String.init)
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
        return try T.init(from: XMLProcessor(node: node, keyMatching: keyMatching))
    }

    private func commonDecode<T>(_ initializer: (String) -> T?) throws -> T {
        switch node.child {
        case .nodes: fatalError("FAIL and throw")
        case .text(let string):
            return try initializer(string) ?? throwError(NSError())
        }
    }

}

func throwError<T>(_ error: @autoclosure () -> Error) throws -> T {
    fatalError("boi")
    throw error()
}

