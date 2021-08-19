import Combine
import Foundation

public extension Service {

    /// Downloads the resource located at the passed in `endpoint` with the
    /// given URL `parameters`.
    /// - Parameters:
    ///   - endpoint: The path extension corresponding to the endpoint.
    ///   - parameters: A dictionary of parameters to be used in the request
    ///   URL query.
    /// - Returns: An [`AnyPublisher`](https://developer.apple.com/documentation/combine/anypublisher)
    /// which publishes a URL to the downloaded file upon success.
    @available(*, deprecated, message: "Construct a request with HTTP.Request.download(_:) and use Service/perform(_:) instead.")
    func download(_ endpoint: String, parameters: [String: Any] = [:]) -> AnyPublisher<URL, Error> {
        perform(HTTP.Request.download(endpoint).parameters(parameters))
    }

}
