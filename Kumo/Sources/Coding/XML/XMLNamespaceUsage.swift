import Foundation

public enum XMLNamespaceUsage {

    /// Defines an assortment of XML namespaces, using the first namespace for the current node.
    case define(using: XMLNamespace, including: [XMLNamespace])

    /// Uses the given namespace for the current node.
    case use(XMLNamespace)

    /// Defines and uses the namespace for the current node and uses it for all its descendants.
    case defineBeneath(XMLNamespace)

    /// Uses the given namespace for the current node and all its descendants.
    case useBeneath(XMLNamespace)

    public var namespace: XMLNamespace {
        switch self {
        case .define(using: let namespace, including: _): return namespace
        case .use(let namespace): return namespace
        case .defineBeneath(let namespace): return namespace
        case .useBeneath(let namespace): return namespace
        }
    }

}
