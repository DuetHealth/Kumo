import RxSwift

public extension Service {

    public func post<Body: Encodable, Response: Decodable>(_ endpoint: String, parameters: [String: Any] = [:], body: Body, keyedUnder key: String? = nil) -> Observable<Response> {
        return dataTask(method: .post, endpoint, parameters: parameters, body: body, keyedUnder: key)
    }

    public func post<Body: Encodable>(_ endpoint: String, parameters: [String: Any] = [:], body: Body) -> Observable<Void> {
        return dataTask(method: .post, endpoint, parameters: parameters, body: body)
    }

    public func post<Body: Encodable>(_ endpoint: String, parameters: [String: Any] = [:], body: Body) -> Observable<Any> {
        return dataTask(method: .post, endpoint, parameters: parameters, body: body)
    }

    public func post<Response: Decodable>(_ endpoint: String, parameters: [String: Any] = [:], body: [String: Any], keyedUnder key: String? = nil) -> Observable<Response> {
        return dataTask(method: .post, endpoint, parameters: parameters, body: body, keyedUnder: key)
    }

    public func post(_ endpoint: String, parameters: [String: Any] = [:], body: [String: Any]) -> Observable<Void> {
        return dataTask(method: .post, endpoint, parameters: parameters, body: body)
    }

    public func post(_ endpoint: String, parameters: [String: Any] = [:], body: [String: Any]) -> Observable<Any> {
        return dataTask(method: .post, endpoint, parameters: parameters, body: body)
    }

}
