import Foundation

public protocol ThrowingDataRepresentable {
    associatedtype RepresentationArguments
    init(data: Data, using arguments: RepresentationArguments) throws
}

public protocol DirectThrowingDataRepresentable: ThrowingDataRepresentable where RepresentationArguments == Void {
    init(data: Data) throws
}

public extension DirectThrowingDataRepresentable {

    init(data: Data, using arguments: Void) throws {
        try self.init(data: data)
    }

}
