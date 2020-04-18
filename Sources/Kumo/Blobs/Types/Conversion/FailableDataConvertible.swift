import Foundation

public protocol FailableDataConvertible: _DataConvertible where _ConversionArguments == ConversionArguments {
    associatedtype ConversionArguments
    func data(using arguments: ConversionArguments) -> Data?
}

public protocol DirectFailableDataConvertible: FailableDataConvertible where ConversionArguments == Void {
    func data() -> Data?
}

public extension DirectFailableDataConvertible {

    func data(using arguments: Void) -> Data? {
        return data()
    }

}
