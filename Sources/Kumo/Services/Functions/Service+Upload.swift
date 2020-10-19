import Combine
import Foundation

public extension Service {
    /// Uploads to an endpoint the provided file. The file is uploaded as form data
    /// under the supplied key.
    ///
    /// - Parameters:
    ///   - endpoint: the path extension corresponding to the endpoint
    ///   - file: the URL of the file to upload
    ///   - key: the name of form part under which to embed the file's data
    /// - Returns: an `AnyPublisher` which emits a single empty element upon success.
    func upload(_ endpoint: String, parameters: [String: Any] = [:], file: URL, under key: String) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            do {
                var request = try self.createRequest(method: .post, endpoint: endpoint, queryParameters: parameters)
                guard file.isFileURL else { throw UploadError.notAFileURL(file) }
                let form = try MultipartForm(file: file, under: key, encoding: .utf8)
                request.set(contentType: .multipartFormData(boundary: form.boundary))
                let task = self.session.uploadTask(with: request, from: form.data) {
                    let result: Result<Void, Error> = self.result(data: $0, response: $1, error: $2)
                    self.fulfill(promise: promise, for: result)
                }
                task.resume()
            } catch {
                promise(.failure(error))
            }
        }
        .subscribe(on: subscriptionScheduler)
        .receive(on: receivingScheduler)
        .eraseToAnyPublisher()
    }

    /// Uploads to an endpoint the provided file. The file is uploaded as form data
    /// under the supplied key.
    ///
    /// - Parameters:
    ///   - endpoint: the path extension corresponding to the endpoint
    ///   - file: the URL of the file to upload
    ///   - key: the name of form part under which to embed the file's data
    /// - Returns: an `AnyPublisher` which emits the progress of the upload.
    func upload(_ endpoint: String, parameters: [String: Any] = [:], file: URL, under key: String) -> AnyPublisher<Double, Error> {
        AnyPublisher<URLSessionUploadTask, Error>.create { subscriber in
            var task = URLSessionUploadTask?.none
            do {
                var request = try self.createRequest(method: .post, endpoint: endpoint, queryParameters: parameters)
                guard file.isFileURL else { throw UploadError.notAFileURL(file) }
                let form = try MultipartForm(file: file, under: key, encoding: .utf8)
                request.set(contentType: .multipartFormData(boundary: form.boundary))
                task = self.session.uploadTask(with: request, from: form.data) {
                    let result: Result<Void, Error> = self.result(data: $0, response: $1, error: $2)
                    switch result {
                    case let .failure(error): subscriber.onError(error)
                    case .success: subscriber.onComplete()
                    }
                }
                guard let task = task else { return AnyCancellable {} }
                subscriber.onNext(task)
                task.resume()
            } catch {
                subscriber.onError(error)
            }
            return AnyCancellable {
                task?.cancel()
            }
        }
        .map {
            $0.progress.kumo.fractionComplete
                .eraseToAnyPublisher()
                .setFailureType(to: Error.self)
        }
        .switchToLatest()
        .eraseToAnyPublisher()
    }
}
