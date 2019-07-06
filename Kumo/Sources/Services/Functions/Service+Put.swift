import RxSwift

public extension Service {
    
    func put<Body: Encodable, Response: Decodable>(_ endpoint: String, parameters: [String: Any] = [:], body: Body, keyedUnder key: String? = nil) -> Observable<Response> {
        return dataTask(method: .put, endpoint, parameters: parameters, body: body, keyedUnder: key)
    }

    func put<Body: Encodable>(_ endpoint: String, parameters: [String: Any] = [:], body: Body, keyedUnder key: String? = nil) -> Observable<Void> {
        return dataTask(method: .put, endpoint, parameters: parameters, body: body, keyedUnder: key)
    }

    func put<Body: Encodable>(_ endpoint: String, parameters: [String: Any] = [:], body: Body, keyedUnder key: String? = nil) -> Observable<Any> {
        return dataTask(method: .put, endpoint, parameters: parameters, body: body, keyedUnder: key)
    }

    func put<Response: Decodable>(_ endpoint: String, parameters: [String: Any] = [:], body: [String: Any], keyedUnder key: String? = nil) -> Observable<Response> {
        return dataTask(method: .put, endpoint, parameters: parameters, body: body, keyedUnder: key)
    }

    func put(_ endpoint: String, parameters: [String: Any] = [:], body: [String: Any], keyedUnder key: String? = nil) -> Observable<Void> {
        return dataTask(method: .put, endpoint, parameters: parameters, body: body, keyedUnder: key)
    }

    func put(_ endpoint: String, parameters: [String: Any] = [:], body: [String: Any], keyedUnder key: String? = nil) -> Observable<Any> {
        return dataTask(method: .put, endpoint, parameters: parameters, body: body, keyedUnder: key)
    }
    
}
