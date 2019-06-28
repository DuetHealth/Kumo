import Foundation

class XMLConstructor: Encoder {

    let context: XMLNodeWritingContext
    private let strategies: XMLEncodingStrategies

    var codingPath: [CodingKey] = []

    var userInfo: [CodingUserInfoKey: Any] {
        return strategies.userInfo
    }

    init(context: XMLNodeWritingContext = XMLNodeWritingContext(), strategies: XMLEncodingStrategies) {
        self.context = context
        self.strategies = strategies
    }

    func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
        return KeyedEncodingContainer(KeyedXMLEncodingContainer(context: context, strategies: strategies))
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        // NOTE: for arrays.
        fatalError("""
        If you're reading this, you must need it.
        I didn't need it, so I didn't implement it.
        I don't understand XML.
        Please forgive me and implement this.
        """)
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        // NOTE: I don't think this is really ever useful since XML must be a node-based tree.
        fatalError("""
        If you're reading this, you must need it.
        I didn't need it, so I didn't implement it.
        I don't understand XML.
        Please forgive me and implement this.
        """)
    }

}
