import Foundation

public protocol _DataConvertible {
    associatedtype _ConversionArguments
    func data(using arguments: _ConversionArguments) throws -> Data?
}
