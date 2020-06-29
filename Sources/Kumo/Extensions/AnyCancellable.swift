import Combine
import Foundation

fileprivate var cancellablesKey = UInt8.zero

public extension Cancellable {

    func withLifetime(of object: AnyObject) {
        var cancellables = objc_getAssociatedObject(self, &cancellablesKey) as? Set<AnyCancellable> ?? Set<AnyCancellable>()
        AnyCancellable(self).store(in: &cancellables)
        objc_setAssociatedObject(self, &cancellables, cancellables, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

}
