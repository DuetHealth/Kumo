import Foundation

public protocol _DataRepresentable {
    associatedtype _RepresentationArguments
    init?(data: Data, using arguments: _RepresentationArguments) throws
}
