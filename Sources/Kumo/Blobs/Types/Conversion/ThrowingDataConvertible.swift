import Foundation

/// A protocol that specifies a throwing method that converts the conforming
/// type to data with given arguments.
public protocol ThrowingDataConvertible: _DataConvertible where _ConversionArguments == ConversionArguments {

    associatedtype ConversionArguments

    /// Converts an instance of the conforming type to a `Data`.
    /// - Returns: A data converted with the given arguments.
    func data(using arguments: ConversionArguments) throws -> Data

}

/// A protocol that specifies a throwing method that converts the conforming
/// type to data.
public protocol DirectThrowingDataConvertible: ThrowingDataConvertible where ConversionArguments == Void {

    /// Converts an instance of the conforming type to a `Data`.
    func data() throws -> Data

}

public extension DirectThrowingDataConvertible {

    func data(using arguments: Void) throws -> Data? {
        return try data()
    }

    func data(using arguments: Void) throws -> Data {
        return try data()
    }

}
