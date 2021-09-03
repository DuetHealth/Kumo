import Foundation

/// A protocol that allows initialization of the conforming from a representing
/// data through the given arguments.
public protocol FailableDataRepresentable: _DataRepresentable where _RepresentationArguments == RepresentationArguments {

    associatedtype RepresentationArguments

    /// Creates an instance of the conforming type from representing `data`
    /// and `arguments`.
    init?(data: Data, using arguments: RepresentationArguments)

}

/// A protocol that allows initialization of the conforming from a representing
/// data.
public protocol DirectFailableDataRepresentable: FailableDataRepresentable where RepresentationArguments == Void {

    /// Creates an instance of the conforming type from representing `data`.
    init?(data: Data)

}

public extension DirectFailableDataRepresentable {

    init?(data: Data, using arguments: Void) {
        self.init(data: data)
    }

}
