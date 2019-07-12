import Foundation

public protocol FailableDataRepresentable {
    associatedtype RepresentationArguments
    init?(data: Data, using arguments: RepresentationArguments)
}

public protocol DirectFailableDataRepresentable: FailableDataRepresentable where RepresentationArguments == Void {
    init?(data: Data)
}

public extension DirectFailableDataRepresentable {

    init?(data: Data, using arguments: Void) {
        self.init(data: data)
    }

}
