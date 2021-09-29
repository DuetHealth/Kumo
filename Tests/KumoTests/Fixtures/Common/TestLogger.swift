import Foundation
@testable import Kumo

class TestLogger: KumoLogger {

    func log(message: String, error: Error?) {
        if error == nil {
            print("API - \(message)")
        } else {
            print("API - Error: \(String(describing: error)) - \(message)")
        }
    }

    var levels: [KumoLoggerLevel] {
        KumoLoggerLevel.all
    }

}
