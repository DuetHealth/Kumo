import Foundation

public protocol ThrowingDataConvertible: _DataConvertible where _ConversionArguments == ConversionArguments {
    associatedtype ConversionArguments
    func data(using arguments: ConversionArguments) throws -> Data
}

public protocol DirectThrowingDataConvertible: ThrowingDataConvertible where ConversionArguments == Void {
    func data() throws -> Data
}

public extension DirectThrowingDataConvertible {

    public func data(using arguments: Void) throws -> Data? {
        return try data()
    }

    public func data(using arguments: Void) throws -> Data {
        return try data()
    }

}
