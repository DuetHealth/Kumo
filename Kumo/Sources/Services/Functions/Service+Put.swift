import RxSwift

public extension Service {

    @available(*, deprecated, message: "Use Service.perform instead.")
    func put<Body: Encodable, Response: Decodable>(_ endpoint: String, parameters: [String: Any] = [:], body: Body, keyedUnder key: String? = nil) -> Observable<Response> {
        return dataTask(method: .put, endpoint, parameters: parameters, body: body, keyedUnder: key)
    }

    @available(*, deprecated, message: "Use Service.perform instead.")
    func put<Body: Encodable>(_ endpoint: String, parameters: [String: Any] = [:], body: Body) -> Observable<Void> {
        return dataTask(method: .put, endpoint, parameters: parameters, body: body)
    }

    @available(*, deprecated, message: "Use Service.perform instead.")
    func put<Body: Encodable>(_ endpoint: String, parameters: [String: Any] = [:], body: Body) -> Observable<Any> {
        return dataTask(method: .put, endpoint, parameters: parameters, body: body)
    }

    @available(*, deprecated, message: "Use Service.perform instead.")
    func put<Response: Decodable>(_ endpoint: String, parameters: [String: Any] = [:], body: [String: Any], keyedUnder key: String? = nil) -> Observable<Response> {
        return dataTask(method: .put, endpoint, parameters: parameters, body: body, keyedUnder: key)
    }

    @available(*, deprecated, message: "Use Service.perform instead.")
    func put(_ endpoint: String, parameters: [String: Any] = [:], body: [String: Any]) -> Observable<Void> {
        return dataTask(method: .put, endpoint, parameters: parameters, body: body)
    }

    @available(*, deprecated, message: "Use Service.perform instead.")
    func put(_ endpoint: String, parameters: [String: Any] = [:], body: [String: Any]) -> Observable<Any> {
        return dataTask(method: .put, endpoint, parameters: parameters, body: body)
    }
    
}
