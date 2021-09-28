import Foundation
@testable import Kumo

class TestLogger: KumoLogger {
    func log(error: Error?, message: String) {
        if error == nil {
            print("API - \(message)")
        } else {
            print("API - Error: \(String(describing: error)) - \(message)")
        }
    }
}
