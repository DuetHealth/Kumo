import Foundation

/// A protocol that allows initialization of the conforming from a representing
/// data through the given arguments.
public protocol ThrowingDataRepresentable: _DataRepresentable where _RepresentationArguments == RepresentationArguments {

    associatedtype RepresentationArguments

    /// Creates an instance of the conforming type from representing `data`
    /// and `arguments`.
    init(data: Data, using arguments: RepresentationArguments) throws

}

public extension ThrowingDataRepresentable {

    init?(data: Data, using arguments: _RepresentationArguments) throws {
        try self.init(data: data, using: arguments)
    }
    
}

/// A protocol that allows initialization of the conforming from a representing
/// data.
public protocol DirectThrowingDataRepresentable: ThrowingDataRepresentable where RepresentationArguments == Void {

    /// Creates an instance of the conforming type from representing `data`.
    init(data: Data) throws

}

public extension DirectThrowingDataRepresentable {

    init(data: Data, using arguments: Void) throws {
        try self.init(data: data)
    }

}
