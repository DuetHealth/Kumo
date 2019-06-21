//
//  XMLNamespace.swift
//  CNS
//
//  Created by ライアン on 6/21/19.
//  Copyright © 2019 Duet Health. All rights reserved.
//

import Foundation

public extension CodingUserInfoKey {
    static let xmlNamespaces = CodingUserInfoKey(rawValue: #function)!
}

public struct XMLNamespace {
    let prefix: String
    let uri: String?

    var attributeName: String {
        return "xmlns:\(prefix)"
    }
}
