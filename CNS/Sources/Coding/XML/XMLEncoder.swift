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
        throw NSError()
    }
    
}

class XMLConstructor: Encoder {

    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey : Any] = [:]

    var root = XMLNode.root

    private let keyConverting: (CodingKey) -> String

    init(keyConverting: @escaping (CodingKey) -> String) {
        self.keyConverting = keyConverting
    }

    func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
        return KeyedEncodingContainer(KeyedXMLEncodingContainer(node: &root, keyConverting: keyConverting))
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

    private var node: XMLNode
    private let keyConverting: (CodingKey) -> String

    init(node: inout XMLNode, keyConverting: @escaping (CodingKey) -> String) {
        self.node = node
        self.keyConverting = keyConverting
    }

    mutating func encodeNil(forKey key: Key) throws {
        
    }

    private mutating func commonEncode(_ value: String, forKey key: Key) throws {
        var newNode = XMLNode(name: keyConverting(key), attributes: [:], child: .text(value))
        switch node.child {
        case .text: throw NSError()
        case .nodes(let nodes): node.child = .nodes(nodes + [newNode])
        }
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
        let constructor = XMLConstructor(keyConverting: keyConverting)
        try value.encode(to: constructor)
        switch (node.child, constructor.root.child) {
        case (.nodes(let ours), .nodes(let theirs)): node.child = .nodes(ours + theirs)
        default: throw NSError()
        }
    }

    mutating func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
        var newNode = XMLNode(name: keyConverting(key), attributes: [:], child: .nodes([]))
        switch node.child {
        case .text: fatalError()
        case .nodes(let nodes): break
        }
        return KeyedEncodingContainer(KeyedXMLEncodingContainer<NestedKey>(node: &node, keyConverting: keyConverting))
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
