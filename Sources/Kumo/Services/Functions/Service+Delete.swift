import RxSwift

public extension Service {

    @available(*, deprecated, message: "Use Service.perform instead.")
    public func delete<Response: Decodable>(_ endpoint: String, parameters: [String: Any] = [:], keyedUnder key: String? = nil) -> Observable<Response> {
        return dataTask(method: .delete, endpoint, parameters: parameters, keyedUnder: key)
    }

    @available(*, deprecated, message: "Use Service.perform instead.")
    public func delete(_ endpoint: String, parameters: [String: Any] = [:]) -> Observable<Void> {
        return dataTask(method: .delete, endpoint, parameters: parameters)
    }

    @available(*, deprecated, message: "Use Service.perform instead.")
    public func delete(_ endpoint: String, parameters: [String: Any] = [:]) -> Observable<Any> {
        return dataTask(method: .delete, endpoint, parameters: parameters)
    }
    
}
