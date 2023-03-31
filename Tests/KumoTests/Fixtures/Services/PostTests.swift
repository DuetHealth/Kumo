import Foundation
import XCTest
@testable import Kumo

class PostTests: NetworkTest {
    
    func testSuccessfulPostRequestWithDynamicBodyEmittingVoid() {
        successfulTest(of: perform(HTTP.Request.post("post").body(["one": ["two": 3]])))
            <| "Will eventually emit Void"
            <| always()
    }
    
    func testSuccessfulPostRequestWithDynamicBodyEmittingElement() {
        successfulTest(of: perform(HTTP.Request.post("anything").body(RequestBody.dynamicBody)))
            <| "Will eventually emit the body which was POSTed"
            <| { (response: MockObjectResponse<RequestBody>) in
                let leaf = RequestBody.dynamicBody["leaf"] as? String
                let integer = (RequestBody.dynamicBody["nested"] as? [String: Any])?["integer"] as? Int
                return response.json.leaf == leaf && response.json.nested.integer == integer
            }
    }
    
}
