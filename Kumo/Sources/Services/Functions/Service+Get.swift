import RxSwift

public extension Service {

    public func get<Response: Decodable>(_ endpoint: String, parameters: [String: Any] = [:], keyedUnder key: String? = nil) -> Observable<Response> {
        return dataTask(method: .get, endpoint, parameters: parameters, keyedUnder: key)
    }

    public func get(_ endpoint: String, parameters: [String: Any] = [:]) -> Observable<Void> {
        return dataTask(method: .get, endpoint, parameters: parameters)
    }

    public func get(_ endpoint: String, parameters: [String: Any] = [:]) -> Observable<Any> {
        return dataTask(method: .get, endpoint, parameters: parameters)
    }
    
}
