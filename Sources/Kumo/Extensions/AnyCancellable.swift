import Combine
import Foundation

fileprivate var cancellablesKey = UInt8.zero

extension Cancellable {

    func withLifetime(of object: AnyObject) {
        var cancellables = objc_getAssociatedObject(object, &cancellablesKey) as? [AnyCancellable] ?? [AnyCancellable]()
        AnyCancellable(self).store(in: &cancellables)
        objc_setAssociatedObject(object, &cancellables, cancellables, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

}
