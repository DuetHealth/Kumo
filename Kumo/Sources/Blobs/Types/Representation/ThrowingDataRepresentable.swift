import Foundation

public protocol ThrowingDataRepresentable: _DataRepresentable where _RepresentationArguments == RepresentationArguments {
    associatedtype RepresentationArguments
    init(data: Data, using arguments: RepresentationArguments) throws
}

public extension ThrowingDataRepresentable {

    public init?(data: Data, using arguments: _RepresentationArguments) throws {
        try self.init(data: data, using: arguments)
    }
    
}

public protocol DirectThrowingDataRepresentable: ThrowingDataRepresentable where RepresentationArguments == Void {
    init(data: Data) throws
}

public extension DirectThrowingDataRepresentable {

    init(data: Data, using arguments: Void) throws {
        try self.init(data: data)
    }

}
