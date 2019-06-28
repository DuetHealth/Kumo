import Foundation

protocol ImmutableCopying {
    func copy() -> Self
}

protocol MutableCopying: ImmutableCopying {
    associatedtype MutableCopyType
    
    func mutableCopy() -> MutableCopyType
}

extension NSObject: ImmutableCopying { }

extension ImmutableCopying where Self: NSObject {
    
    func copy() -> Self {
        return (self as NSObject).copy() as! Self
    }
    
}
