import RxSwift

public extension Service {
    
    func get<Response: Decodable>(_ endpoint: String, parameters: [String: Any] = [:]) -> Observable<Response> {
        return Observable.create { [self] observer in
            do {
                let request = try self.createRequest(method: .get, endpoint: endpoint, queryParameters: parameters)
                let task = self.session.dataTask(with: request) {
                    observer.on(self.resultToElement(data: $0, response: $1, error: $2))
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
    
    func get(_ endpoint: String, parameters: [String: Any] = [:]) -> Observable<Void> {
        return Observable.create { [self] observer in
            do {
                let request = try self.createRequest(method: .get, endpoint: endpoint, queryParameters: parameters)
                let task = self.session.dataTask(with: request) {
                    observer.on(self.resultToEvent(data: $0, response: $1, error: $2))
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
    
    func get<Response: Decodable>(_ endpoint: String, parameters: [String: Any] = [:], keyedUnder key: String) -> Observable<Response> {
        return Observable.create { [self] observer in
            do {
                let request = try self.createRequest(method: .get, endpoint: endpoint, queryParameters: parameters)
                let task = self.session.dataTask(with: request) {
                    let event: Event<JSONWrapper<Response>> = self.resultToElement(data: $0, response: $1, error: $2)
                    switch event {
                    case .error(let error): return observer.onError(error)
                    case .completed: return observer.onCompleted()
                    case .next(let wrapper):
                        do { try observer.onNext(wrapper.value(forKey: key)) }
                        catch { observer.onError(error) }
                        observer.onCompleted()
                    }
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
