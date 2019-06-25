//
//  XMLDeserializer.swift
//  CNS
//
//  Created by ライアン on 6/21/19.
//  Copyright © 2019 Duet Health. All rights reserved.
//

import Foundation

class XMLDeserializer: NSObject, Decoder, XMLParserDelegate {

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
        guard parser.parse() else {
            throw parser.parserError ?? parsingError ?? DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Could not parse the given data as XML."))
        }
    }

    init(node: XMLNode, keyMatching: @escaping (CodingKey, String) -> Bool) {
        self.keyMatching = keyMatching
        root = node
    }

    func container<Key: CodingKey>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        return KeyedDecodingContainer(KeyedXMLDecodingContainer<Key>(root, keyMatching: keyMatching))
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        throw NSError()
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return SingleValueXMLDecodingContainer(root, keyMatching: keyMatching)
    }

    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        // NOTE: some data which may conflict with XML (i.e. HTML)?
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
        stack.push(XMLNode(name: elementName, attributes: attributeDict))
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        // NOTE: Is this actually an error if false?
        guard stack.peek?.name == elementName else { return }
        let finished = stack.pop()
        stack.update {
            switch $0.child {
            case .nodes(let nodes): $0.child = .nodes(nodes + [finished])
            case .text:
                parsingError = DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "The node \"\($0.name)\" cannot have both a textual leaf child and node children."))
                parser.abortParsing()
            }
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        // NOTE: This _should_ pass most well-formed and not-shitty APIs, but if only whitespace is
        // valid for the textual contents of a node then this will trim it and make the node leaf.
        guard stack.isNotEmpty, string.trimmingCharacters(in: .whitespacesAndNewlines).isNotEmpty else { return }
        stack.update {
            switch $0.child {
            case .nodes(let nodes) where nodes.isNotEmpty:
                parsingError = DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "The node \"\($0.name)\" cannot have both a textual leaf child and node children."))
                parser.abortParsing()
            default: $0.child = .text(string)
            }
        }
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        guard stack.isNotEmpty else { fatalError("Internal error: root node not found.") }
        root = stack.pop()
    }

}
