import Combine
import Foundation

fileprivate var cancellableKey = UInt8.max

public extension AnyCancellable {

    /// Retains the resources associated with a subscription until the argument object is deallocated.
    ///
    /// - Parameter object: the object to which this cancellables lifetime is tethered.
    func withLifetime(of object: AnyObject) {
        if var cancellables = objc_getAssociatedObject(object, &cancellableKey) as? Set<AnyCancellable> {
            self.store(in: &cancellables)
            return
        }
        var cancellables = Set<AnyCancellable>()
        self.store(in: &cancellables)
        objc_setAssociatedObject(object, &cancellableKey, cancellables, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

}
