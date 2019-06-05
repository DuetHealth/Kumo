//
//  SOAPEncoder.swift
//  CNS
//
//  Created by ライアン on 5/20/19.
//  Copyright © 2019 Duet Health. All rights reserved.
//

import Foundation

public class XMLEncoder {

    class EncoderImplementation: Encoder {

        var codingPath: [CodingKey] = []

        var userInfo: [CodingUserInfoKey : Any] = [:]

        func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
            fatalError()
        }

        func unkeyedContainer() -> UnkeyedEncodingContainer {
            fatalError()
        }

        func singleValueContainer() -> SingleValueEncodingContainer {
            fatalError()
        }

    }

    public func encode<T: Encodable>(_ value: T) throws -> Data {
        
        throw NSError()
    }
    
}

extension XMLEncoder: RequestEncoding {

    public var contentType: MIMEType {
        return MIMEType.applicationXML()
    }

}
