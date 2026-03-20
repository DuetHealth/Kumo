import Foundation

public struct _KumoNamespace<Base> {

    public let base: Base

    public init(base: Base) {
        self.base = base
    }

}

public protocol _KumoCompatible {

    associatedtype CompatibleType
    var kumo: _KumoNamespace<CompatibleType> { get }

}

extension _KumoCompatible {

    public static var kumo: _KumoNamespace<Self.Type> {
        return _KumoNamespace(base: Self.self)
    }

    public var kumo: _KumoNamespace<Self> {
        return _KumoNamespace(base: self)
    }

}

extension NSObject: _KumoCompatible {}
