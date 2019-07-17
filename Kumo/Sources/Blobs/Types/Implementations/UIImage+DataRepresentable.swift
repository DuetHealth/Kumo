#if canImport(UIKit)
import Foundation
import UIKit
extension UIImage: DirectFailableDataRepresentable { }
extension UIImage: DirectFailableDataConvertible {
    public func data() -> Data? {
        return pngData()
    }
}
#endif
