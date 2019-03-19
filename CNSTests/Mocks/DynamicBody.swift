//
//  RequestBody.swift
//  CNSTests
//
//  Created by ライアン on 3/3/19.
//  Copyright © 2019 Duet Health. All rights reserved.
//

import Foundation

struct RequestBody: Codable {

    struct NestedBody: Codable {
        let integer: Int
    }
    
    static let dynamicBody: [String: Any] = ["nested": ["integer": 3], "leaf": "string"]

    let nested: NestedBody
    let leaf: String
    
}
