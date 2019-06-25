//
//  HashedCodingKey.swift
//  CNS
//
//  Created by ライアン on 6/21/19.
//  Copyright © 2019 Duet Health. All rights reserved.
//

import Foundation

struct HashedCodingKey: Hashable {

    private let hashedValue: AnyHashable

    init(_ codingKey: CodingKey) {
        hashedValue = AnyHashable(codingKey.stringValue)
    }

}

extension Dictionary where Key == HashedCodingKey {

    subscript(_ codingKey: CodingKey) -> Value? {
        get { return self[HashedCodingKey(codingKey)] }
        set { self[HashedCodingKey(codingKey)] = newValue }
    }

}
