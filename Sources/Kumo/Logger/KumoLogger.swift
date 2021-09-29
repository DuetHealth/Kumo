import Combine
import Foundation

public protocol KumoLogger {

    func log(message: String, error: Error?)

    /// The array of KumoLoggerLevel to log. Used to control how fine grain the logging is. If this array is empty that is the same as disabling logging
    var levels: [KumoLoggerLevel] { get }

}

/// Controlls the level of logging in Kumo.
public enum KumoLoggerLevel: CaseIterable {
    /// Logs the URLRequest inculding errors.
    case request
    /// Logs the URLResponse inculding errors.
    case response
    /// Logs the response data as a String including errors.
    case responseData
    /// Logs the result of the response data decoding inculding errors.
    case responseDecoding
    /// Only logs errors.
    case error
    
    /// Adds all of the logging levels.
    public static var all: [KumoLoggerLevel] {
        allCases
    }
    
}

extension KumoLogger {

    func logRequest(_ request: URLRequest) {
        guard levels.contains(.request) else {
            return
        }
        log(message: "Request: \(request)", error: nil)
    }

    func logRequestError(_ error: Error) {
        // If error is set ignore this log. The error will get caught in the publisher.
        guard levels.contains(.request), !levels.contains(.error) else {
            return
        }
        log(message: "Error with request", error: error)
    }

    func logResponse(_ response: URLResponse) {
        guard levels.contains(.response) else {
            return
        }
        log(message: "Response: \(response)", error: nil)
    }

    func logResponseError(_ error: Error) {
        // If error is set ignore this log. The error will get caught in the publisher.
        guard levels.contains(.response), !levels.contains(.error) else {
            return
        }
        log(message: "Error with response", error: error)
    }

    func logRawResponse(_ data: Data?) {
        guard levels.contains(.responseData) else {
            return
        }
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
            guard let logger = logger, logger.levels.contains(.responseDecoding) else {
                return
            }
            logger.log(message: "Decoded Response: \(output)", error: nil)
        }, receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                guard let logger = logger, logger.levels.contains(.responseDecoding) || logger.levels.contains(.error) else {
                    return
                }
                logger.log(message: "Error with request or response", error: error)
            case .finished:
                ()
            }
        })
    }

}
