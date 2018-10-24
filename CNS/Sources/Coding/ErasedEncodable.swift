//
//  ErasedEncodable.swift
//  DHKApi
//
//  Created by Ryan Wachowski on 8/6/18.
//  Copyright © 2018 Duet Health. All rights reserved.
//

import Foundation

struct ErasedEncodable: Encodable {

    let base: Encodable
    private let implementation: (Encoder) throws -> ()

    init(_ base: Encodable) {
        self.base = base
        self.implementation = base.encode(to:)
    }

    func encode(to encoder: Encoder) throws {
        try implementation(encoder)
    }

}
