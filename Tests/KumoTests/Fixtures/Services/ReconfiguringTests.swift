import Combine
import Foundation
@testable import Kumo
import XCTest

import Foundation

class ReconfiguringTests: NetworkTest {
    func testReconfiguring() {
        let service = Service(baseURL: URL(string: "https://speed.hetzner.de")!, logger: TestLogger())
        let expectation = XCTestExpectation()
        var cancellables = Set<AnyCancellable>()

        service.perform(HTTP.Request.get("100MB.bin"))
            .sink(receiveCompletion: { _ in
                print("Finished large download")
            }, receiveValue: {

            })
            .store(in: &cancellables)
        service.reconfiguring(applying:  { configuration in
            configuration.headers.set(value: "Test Reconfigure", for: .custom("TEST"))
            print("Finished reconfiguring")
        })
        .setFailureType(to: Error.self)
        .flatMap { _ in
            service.perform(HTTP.Request.get("test100k.db"))
        }
        .sink(receiveCompletion: { _ in
            print("Finished small download")
            expectation.fulfill()
        }, receiveValue: { _ in

        })
        .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)
    }
}
