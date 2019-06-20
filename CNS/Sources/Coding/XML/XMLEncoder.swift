//
//  SOAPEncoder.swift
//  CNS
//
//  Created by ライアン on 5/20/19.
//  Copyright © 2019 Duet Health. All rights reserved.
//

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

    public var keyEncodingStrategy = KeyEncodingStrategy.useDefaultKeys

    public init() { }

    public func encode<T: Encodable>(_ value: T) throws -> Data {
        let constructor = XMLConstructor(keyConverting: keyEncodingStrategy.convert(key:))
        try value.encode(to: constructor)
        try print(constructor.context.read())
        fatalError()
    }
    
}

class XMLNodeWritingContext {

    private var stack = StackDecorator([XMLNode.root])

    func addNested(node: XMLNode) {
        stack.push(node)
    }

    func addLeaf(node: XMLNode) throws {
        try stack.update { top in
            switch top.child {
            case .text: throw NSError()
            case .nodes(let nodes): top.child = .nodes(nodes + [node])
            }
        }
    }

    func read() throws -> XMLNode {
        // TODO: build a tree. Right now this does nothing.
        return stack.peek!
    }

}

class XMLConstructor: Encoder {

    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey : Any] = [:]

    let context = XMLNodeWritingContext()

    private let keyConverting: (CodingKey) -> String

    init(context: XMLNodeWritingContext = XMLNodeWritingContext(), keyConverting: @escaping (CodingKey) -> String) {
        self.keyConverting = keyConverting
    }

    func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
        return KeyedEncodingContainer(KeyedXMLEncodingContainer(context: context, keyConverting: keyConverting))
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError()
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        fatalError()
    }

}

struct KeyedXMLEncodingContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {

    var codingPath: [CodingKey] = []

    private let context: XMLNodeWritingContext
    private let keyConverting: (CodingKey) -> String

    init(context: XMLNodeWritingContext, keyConverting: @escaping (CodingKey) -> String) {
        self.context = context
        self.keyConverting = keyConverting
    }

    mutating func encodeNil(forKey key: Key) throws {
        // TODO: apparently nil is encoded as xsi:nil="true"
    }

    private mutating func commonEncode(_ value: String, forKey key: Key) throws {
        try context.addLeaf(node: XMLNode(name: keyConverting(key), attributes: [:], child: .text(value)))
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
        let constructor = XMLConstructor(context: XMLNodeWritingContext(), keyConverting: keyConverting)
        try value.encode(to: constructor)
        try context.addNested(node: XMLNode(name: keyConverting(key), attributes: [:], child: .nodes([constructor.context.read()])))
    }

    mutating func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
        return KeyedEncodingContainer(KeyedXMLEncodingContainer<NestedKey>(context: context, keyConverting: keyConverting))
    }

    mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        fatalError()
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

}



extension XMLEncoder: RequestEncoding {

    public var contentType: MIMEType {
        return MIMEType.applicationXML()
    }

}
