import Combine
import Foundation

private var cancellablesKey: Void?

extension Cancellable {

    func withLifetime(of object: AnyObject) {
        var cancellables = objc_getAssociatedObject(object, &cancellablesKey) as? [AnyCancellable] ?? [AnyCancellable]()
        AnyCancellable(self).store(in: &cancellables)
        objc_setAssociatedObject(object, &cancellablesKey, cancellables, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

}
