import Foundation

enum CacheDeserializationError<T>: Error {
    case initializationFailed(T.Type, data: Data)
}

struct AnyDataRepresentable<Result, Arguments> {

    private let implementation: (Data, Arguments) throws -> Result

    static func abstract<Result: FailableDataRepresentable>(_ type: Result.Type) -> AnyDataRepresentable<Result, Result.RepresentationArguments> {
        return AnyDataRepresentable<Result, Result.RepresentationArguments>.init { (data: Data, arguments: Result.RepresentationArguments) -> Result in
            guard let result = Result.init(data: data, using: arguments) else {
                throw CacheDeserializationError.initializationFailed(Result.self, data: data)
            }
            return result
        }
    }

    static func abstract<Result: ThrowingDataRepresentable>(_ type: Result.Type) -> AnyDataRepresentable<Result, Result.RepresentationArguments> {
        return AnyDataRepresentable<Result, Result.RepresentationArguments>.init(Result.init(data:using:))
    }

    private init(_ implementation: @escaping (Data, Arguments) throws -> Result) {
        self.implementation = implementation
    }

    func convert(_ data: Data, using arguments: Arguments) throws -> Result {
        return try implementation(data, arguments)
    }

}
