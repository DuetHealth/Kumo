import Combine
import Foundation

public extension Service {

    /// Uploads to an endpoint the provided file. The file is uploaded as form data
    /// under the supplied key.
    ///
    /// - Parameters:
    ///   - endpoint: The path extension corresponding to the endpoint.
    ///   - file: The URL of the file to upload.
    ///   - key: The name of form part under which to embed the file's data.
    /// - Returns: An [`AnyPublisher`](https://developer.apple.com/documentation/combine/anypublisher)
    /// which publishes upon success.
    @available(*, deprecated, message: "Construct an HTTP.Request with `.upload(_:)` and use `perform` instead.")
    func upload<Response: Decodable>(_ endpoint: String, file: URL, under key: String) async throws -> Response? {
        try await perform(HTTP.Request.upload(endpoint).file(file).keyed(under: key))
    }

    /// Uploads to an endpoint the provided file. The file is uploaded as form data
    /// under the supplied key.
    ///
    /// - Parameters:
    ///   - endpoint: The path extension corresponding to the endpoint.
    ///   - parameters: A dictionary of parameters to be used in the request
    ///   URL query.
    ///   - file: The URL of the file to upload
    ///   - key: The name of form part under which to embed the file's data
    /// - Returns: An [`AnyPublisher`](https://developer.apple.com/documentation/combine/anypublisher)
    /// which publishes a single empty element upon success.
    @available(*, deprecated, message: "Construct an HTTP.Request with `.upload(_:)` and use `perform` instead.")
    func upload(_ endpoint: String, parameters: [String: Any] = [:], file: URL, under key: String) async throws {
        try await perform(HTTP.Request.upload(endpoint).parameters(parameters).file(file).keyed(under: key))
    }

    /// Uploads to an endpoint the provided file. The file is uploaded as form data
    /// under the supplied key.
    ///
    /// - Parameters:
    ///   - endpoint: The path extension corresponding to the endpoint.
    ///   - parameters: A dictionary of parameters to be used in the request
    ///   URL query.
    ///   - file: The URL of the file to upload.
    ///   - key: The name of form part under which to embed the file's data.
    /// - Returns: An [`AnyPublisher`](https://developer.apple.com/documentation/combine/anypublisher)
    /// which publishes the progress of the upload.
    @available(*, deprecated, message: "Construct an HTTP.Request with `.upload(_:)` and use `perform` with `.progress()` instead.")
    func uploads(_ endpoint: String, parameters: [String: Any] = [:], file: URL, under key: String) async throws -> Double {
        try await perform(HTTP.Request.upload(endpoint).parameters(parameters).file(file).keyed(under: key).progress())
    }

}
