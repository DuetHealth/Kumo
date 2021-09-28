import Foundation
import Combine


public protocol KumoLogger {
 
    func log(error: Error?, message: String)
}

extension KumoLogger {
    
    func logRequest(_ request: URLRequest) {
        log(error: nil, message: "Request: \(request)")
    }
    
    func logError(_ error: Error) {
        log(error: error, message: "Error with request")
    }
    
    func logRawResponse(_ data: Data?) {
        if let data = data {
            log(error: nil, message: "Raw Response: \(String(data: data, encoding: .utf8) ?? "Error converting to String")")
        } else {
            log(error: nil, message: "Raw Response: nil")
        }
    }
}

extension Publisher {
    func logPublisher(_ logger: KumoLogger?) -> Publishers.HandleEvents<Self> {
        handleEvents(receiveOutput: { output in
            logger?.log(error: nil, message: "Sucess: \(output)")
        }, receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                logger?.log(error: error, message: "Error with request")
            case .finished:
                ()
            }
        })
    }
}
