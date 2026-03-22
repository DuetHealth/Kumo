import Combine
import Foundation

private nonisolated(unsafe) var cancellablesKey: UInt8 = 0

extension Cancellable {

    func withLifetime(of object: AnyObject) {
        var cancellables = objc_getAssociatedObject(object, &cancellablesKey) as? [AnyCancellable] ?? [AnyCancellable]()
        AnyCancellable(self).store(in: &cancellables)
        objc_setAssociatedObject(object, &cancellablesKey, cancellables, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

}
