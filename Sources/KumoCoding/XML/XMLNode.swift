import Foundation

struct XMLNode {

    enum Child {
        case nodes([XMLNode])
        case text(String)
    }

    static var sentinel: XMLNode {
        return XMLNode()
    }

    var name: String
    var attributes: [String: String]
    var child: Child

    let isSentinel: Bool

    init(name: String, attributes: [String: String] = [:], child: Child = .nodes([])) {
        self.name = name
        self.attributes = attributes
        self.child = child
        isSentinel = false
    }

    private init() {
        name = ""
        attributes = [:]
        child = .nodes([])
        isSentinel = true
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
