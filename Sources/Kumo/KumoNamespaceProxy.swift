import Foundation

public struct KumoNamespace<Base> {

    let base: Base

    internal init(base: Base) {
        self.base = base
    }

}

public protocol KumoCompatible {

    associatedtype CompatibleType
    var kumo: KumoNamespace<CompatibleType> { get }

}

extension KumoCompatible {

    public static var kumo: KumoNamespace<Self.Type> {
        return KumoNamespace(base: Self.self)
    }

    public var kumo: KumoNamespace<Self> {
        return KumoNamespace(base: self)
    }

}

extension NSObject: KumoCompatible {}
