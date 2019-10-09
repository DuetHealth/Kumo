import Foundation

class XMLNodeWritingContext {

    var root: XMLNode {
        return stack.array.first!
    }

    private var stack: StackDecorator<XMLNode>

    init(node: XMLNode = .sentinel) {
        stack = StackDecorator([node])
    }

    func addNested(node: XMLNode) {
        stack.push(node)
    }

    func addLeaf(node: XMLNode) throws {
        try stack.update { top in
            switch top.child {
            case .text: throw NSError(domain: "com.duet.kumo.xmlnodewritingcontext", code: 1, userInfo: [:])
            case .nodes(let nodes): top.child = .nodes(nodes + [node])
            }
        }
    }

    func consumeNode() -> XMLNode {
        return stack.pop()
    }

    func consumeContext() throws -> String {
        while stack.array.count > 1 {
            try addLeaf(node: stack.pop())
        }
        return "<?xml version=\"1.0\"?>\(recursiveWrite(node: stack.peek!))"
    }

    private func recursiveWrite(node: XMLNode) -> String {
        let attributeString = node.attributes.reduce("") { "\($0) \($1.key)=\"\($1.value)\"" }
        let rootPattern = node.isSentinel ? "%@" : "<\(node.name)\(attributeString)>%@</\(node.name)>"
        let emptyPattern = "<\(node.name)\(attributeString)/>"
        switch node.child {
        case .text(let text) where text.isEmpty: return emptyPattern
        case .text(let text): return String(format: rootPattern, text)
        case .nodes(let nodes) where nodes.isEmpty: return emptyPattern
        case .nodes(let nodes): return String(format: rootPattern, nodes.map(recursiveWrite(node:)).joined())
        }
    }

}
