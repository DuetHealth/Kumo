import Combine
import Foundation


public protocol KumoLogger {
 
    func log(message: String, error: Error?)
    
}

extension KumoLogger {
    
    func logRequest(_ request: URLRequest) {
        log(message: "Request: \(request)", error: nil)
    }
    
    func logError(_ error: Error) {
        log(message: "Error with request", error: nil)
    }
    
    func logRawResponse(_ data: Data?) {
        if let data = data {
            log(message: "Raw Response: \(String(data: data, encoding: .utf8) ?? "Error converting to String")", error: nil)
        } else {
            log(message: "Raw Response: nil", error: nil)
        }
    }
    
}

extension Publisher {
    
    func logPublisher(_ logger: KumoLogger?) -> Publishers.HandleEvents<Self> {
        handleEvents(receiveOutput: { output in
            logger?.log( message: "Sucess: \(output)", error: nil)
        }, receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                logger?.log(error: error, message: "Error with request", error: nil)
            case .finished:
                ()
            }
        })
    }
    
}
