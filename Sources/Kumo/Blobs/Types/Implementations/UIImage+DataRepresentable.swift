import Foundation

#if canImport(UIKit)
import UIKit
extension UIImage: DirectFailableDataRepresentable { }
extension UIImage: DirectFailableDataConvertible {
    public func data() -> Data? {
        return pngData()
    }
}
#endif

extension Data: _DataRepresentable {
    public typealias _RepresentationArguments = Void
    public init?(data: Data, using arguments: Void) throws {
        self.init(bytes: data)
    }
}

extension Data: _DataConvertible {
    public typealias _ConversionArguments = Void
    public func data(using arguments: Void) throws -> Data? {
        return self
    }
}
