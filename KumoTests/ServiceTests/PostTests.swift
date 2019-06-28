//
//  GetTests.swift
//  CNSTests
//
//  Created by ライアン on 3/2/19.
//  Copyright © 2019 Duet Health. All rights reserved.
//

import Foundation
import XCTest
@testable import Kumo

class PostTests: NetworkTest {
    
    func testSuccessfulPostRequestWithDynamicBodyEmittingVoid() {
        successfulTest(of: service.post("post", body: ["one": ["two": 3]]))
            <| "Will eventually emit Void"
            <| always()
    }
    
    func testSuccessfulPostRequestWithDynamicBodyEmittingElement() {
        successfulTest(of: service.post("anything", body: RequestBody.dynamicBody))
            <| "Will eventually emit the body which was POSTed"
            <| { (response: RequestBody) in
                let leaf = RequestBody.dynamicBody["leaf"] as? String
                let integer = (RequestBody.dynamicBody["nested"] as? [String: Any])?["integer"] as? Int
                return response.leaf == leaf && response.nested.integer == integer
            }
    }
    
}
