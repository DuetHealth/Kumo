import Foundation

/// A protocol that specifies a method of converting the conforming type to
/// data with given arguments.
public protocol FailableDataConvertible: _DataConvertible where _ConversionArguments == ConversionArguments {

    associatedtype ConversionArguments

    /// Converts an instance of the conforming type to a `Data`.
    /// - Returns: A data converted with the given arguments.
    func data(using arguments: ConversionArguments) -> Data?

}

/// A protocol that specifies a method of converting the conforming type to
/// data.
public protocol DirectFailableDataConvertible: FailableDataConvertible where ConversionArguments == Void {

    /// Converts an instance of the conforming type to a `Data`.
    func data() -> Data?

}

public extension DirectFailableDataConvertible {

    func data(using arguments: Void) -> Data? {
        return data()
    }

}
