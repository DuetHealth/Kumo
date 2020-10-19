import Combine
import Foundation

public extension Service {

    func download(_ endpoint: String, parameters: [String: Any] = [:]) -> AnyPublisher<URL, Error> {
        Future<URL, Error> { promise in
            do {
                var request = try self.createRequest(method: .get, endpoint: endpoint, queryParameters: parameters)
                request.remove(header: .accept)
                let task = self.session.downloadTask(with: request) {
                    let result = self.downloadResultToURL(url: $0, response: $1, error: $2)
                    self.fulfill(promise: promise, for: result)
                }
                task.resume()
            } catch {
                promise(.failure(error))
            }
        }
        .receive(on: receivingScheduler)
        .eraseToAnyPublisher()
    }

}
