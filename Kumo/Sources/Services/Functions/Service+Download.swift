import Foundation
import RxSwift

public extension Service {
    
    public func download(_ endpoint: String, parameters: [String: Any] = [:]) -> Observable<URL> {
        return Observable.create { [self] observer in
            do {
                var request = try self.createRequest(method: .get, endpoint: endpoint, queryParameters: parameters)
                request.remove(header: .accept)
                let task = self.session.downloadTask(with: request) {
                    observer.on(self.downloadResultToURL(url: $0, response: $1, error: $2))
                    observer.onCompleted()
                }
                task.resume()
                return Disposables.create(with: task.cancel)
            } catch {
                observer.onError(error)
                return Disposables.create()
            }
        }
            .observeOn(operationScheduler)
    }
    
}
