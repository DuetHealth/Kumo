import Foundation
import XCTest
@testable import Kumo

class GetTests: NetworkTest {
    
    func testSuccessfulGetRequestEmittingVoid() {
        successfulTest(of: performs(HTTP.Request.get("get")))
            <| "Will eventually emit Void"
            <| always()
    }
    
    func testSuccessfulGetRequestEmittingAnElement() {
        successfulTest(of: perform(HTTP.Request.get("get")))
            <| "Will eventually emit a mock response"
            <| (always() as (MockResponse) -> Bool)
    }
    
    func testSuccessfulGetRequestWithParametersEmittingVoid() {
        successfulTest(of: performs(HTTP.Request.get("get").parameters(parameters.actual)))
            <| "Will eventually emit a mock response with the provided parameters"
            <| always()
    }

    func testSuccessfulGetRequestWithParametersEmittingElement() {
        successfulTest(of: perform(HTTP.Request.get("get").parameters(parameters.actual)))
            <| "Will eventually emit a mock response with the provided parameters"
            <| { (response: MockResponse) in
                response.args == self.parameters.expected
            }
    }

    func testSuccessfulGetRequestAccessingElementKeyedUnderKey() {
        successfulTest(of: perform(HTTP.Request.get("get").keyed(under: "url")))
            <| "Will eventually emit the value under the key 'url' in the mock response"
            <| (always() as (URL) -> Bool)
    }
    
    func testSuccessfulGetRequestWithParametersAccessingElementKeyedUnderKey() {
        successfulTest(of: perform(HTTP.Request.get("get").parameters(parameters.actual).keyed(under: "args")))
            <| "Will eventually emit the value under the key 'args' in the mock response"
            <| { (args: [String: String]) in
                args == self.parameters.expected
            }
    }
    
    func testUnsuccessfulGetRequestEndsInError() {
        erroringTest(of: performs(HTTP.Request.get("status/401")))
            <| "Will eventually emit an error"
            <| { (error: Error) in
                guard let responseObjectError = error as? ResponseObjectError else { return false }
                guard case .some(HTTPError.ambiguousError(.unauthorized401)) = responseObjectError.wrappedError as? HTTPError else { return false }
                return true
            }
    }
    
}
