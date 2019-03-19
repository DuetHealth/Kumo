//
//  MockGetResponse.swift
//  CNSTests
//
//  Created by ライアン on 3/2/19.
//  Copyright © 2019 Duet Health. All rights reserved.
//

import Foundation

struct MockResponse: Codable {
    let args: [String: String]
    let headers: [String: String]
    let origin: String
    let url: URL
}
