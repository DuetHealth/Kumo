import RxSwift

extension Service {

    func dataTask<Body: Encodable, Response: Decodable>(method: HTTP.Method, _ endpoint: String, parameters: [String: Any] = [:], body: Body? = nil, keyedUnder key: String? = nil) -> Observable<Response> {
        return Observable.create { [self] observer in
            do {
                let request = try self.createRequest(method: method, endpoint: endpoint, queryParameters: parameters, body: body)
                return self.response(keyedUnder: key, forRequest: request, observer: observer)
            } catch {
                observer.onError(error)
                return Disposables.create()
            }
        }
        .observeOn(operationScheduler)
    }

    func dataTask<Body: Encodable>(method: HTTP.Method, _ endpoint: String, parameters: [String: Any] = [:], body: Body? = nil) -> Observable<Void> {
        return Observable.create { [self] observer in
            do {
                let request = try self.createRequest(method: method, endpoint: endpoint, queryParameters: parameters, body: body)
                return self.response(forRequest: request, observer: observer)
            } catch {
                observer.onError(error)
                return Disposables.create()
            }
        }
        .observeOn(operationScheduler)
    }

    func dataTask<Body: Encodable>(method: HTTP.Method, _ endpoint: String, parameters: [String: Any] = [:], body: Body? = nil) -> Observable<Any> {
        return Observable.create { [self] observer in
            do {
                let request = try self.createRequest(method: method, endpoint: endpoint, queryParameters: parameters, body: body)
                return self.response(forRequest: request, observer: observer)
            } catch {
                observer.onError(error)
                return Disposables.create()
            }
        }
        .observeOn(operationScheduler)
    }

    func dataTask<Response: Decodable>(method: HTTP.Method, _ endpoint: String, parameters: [String: Any] = [:], body: [String: Any]? = nil, keyedUnder key: String? = nil) -> Observable<Response> {
        return Observable.create { [self] observer in
            do {
                let request = try self.createRequest(method: method, endpoint: endpoint, queryParameters: parameters, body: body)
                return self.response(keyedUnder: key, forRequest: request, observer: observer)
            } catch {
                observer.onError(error)
                return Disposables.create()
            }
        }
        .observeOn(operationScheduler)
    }

    func dataTask(method: HTTP.Method, _ endpoint: String, parameters: [String: Any] = [:], body: [String: Any]? = nil) -> Observable<Void> {
        return Observable.create { [self] observer in
            do {
                let request = try self.createRequest(method: method, endpoint: endpoint, queryParameters: parameters, body: body)
                return self.response(forRequest: request, observer: observer)
            } catch {
                observer.onError(error)
                return Disposables.create()
            }
        }
        .observeOn(operationScheduler)
    }

    func dataTask(method: HTTP.Method, _ endpoint: String, parameters: [String: Any] = [:], body: [String: Any]? = nil) -> Observable<Any> {
        return Observable.create { [self] observer in
            do {
                let request = try self.createRequest(method: method, endpoint: endpoint, queryParameters: parameters, body: body)
                return self.response(forRequest: request, observer: observer)
            } catch {
                observer.onError(error)
                return Disposables.create()
            }
        }
        .observeOn(operationScheduler)
    }

}
