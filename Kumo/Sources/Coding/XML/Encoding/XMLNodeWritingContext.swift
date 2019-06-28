import Foundation

class XMLNodeWritingContext {

    private var stack: StackDecorator<XMLNode>

    init(node: XMLNode = .root) {
        stack = StackDecorator([node])
    }

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
        let rootPattern = node.isRoot ? "%@" : "<\(node.name)\(attributeString)>%@</\(node.name)>"
        let emptyPattern = "<\(node.name)\(attributeString)/>"
        switch node.child {
        case .text(let text) where text.isEmpty: return emptyPattern
        case .text(let text): return String(format: rootPattern, text)
        case .nodes(let nodes) where nodes.isEmpty: return emptyPattern
        case .nodes(let nodes): return String(format: rootPattern, nodes.map(recursiveWrite(node:)).joined())
        }
    }

}
