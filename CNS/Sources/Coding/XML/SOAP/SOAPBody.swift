//
//  SOAPBody.swift
//  CNS
//
//  Created by ライアン on 5/23/19.
//  Copyright © 2019 Duet Health. All rights reserved.
//

import Foundation

struct SOAPBody<Contents> {

    fileprivate enum SOAPKeys: CodingKey {
        case envelope
        case body
    }

    fileprivate struct TypeKey: CodingKey {

        var intValue: Int?
        var stringValue: String

        init<T>(_ type: T) {
            stringValue = String(describing: type)
        }

        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        init?(intValue: Int) {
            return nil
        }

    }

    let contents: Contents
}

extension SOAPBody: Encodable where Contents: Encodable {

    func encode(to encoder: Encoder) throws {
        var root = encoder.container(keyedBy: SOAPKeys.self)
        var envelope = root.nestedContainer(keyedBy: SOAPKeys.self, forKey: .envelope)
        var body = envelope.nestedContainer(keyedBy: TypeKey.self, forKey: .body)
        try body.encode(contents, forKey: TypeKey(Contents.self))
    }

}

extension SOAPBody: Decodable where Contents: Decodable {

    init(from decoder: Decoder) throws {
        self.contents = try decoder.container(keyedBy: SOAPKeys.self)
            .nestedContainer(keyedBy: SOAPKeys.self, forKey: .envelope)
            .nestedContainer(keyedBy: TypeKey.self, forKey: .body)
            .decode(Contents.self, forKey: TypeKey(Contents.self))
    }

}
