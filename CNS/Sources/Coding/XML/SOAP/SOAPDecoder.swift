//
//  SOAPDecoder.swift
//  CNS
//
//  Created by ライアン on 5/23/19.
//  Copyright © 2019 Duet Health. All rights reserved.
//

import Foundation

public struct XMLNamespace {
    let prefix: String
    let uri: String?
}

public class SOAPDecoder {

    private let baseDecoder: XMLDecoder

    public var soapNamespace = XMLNamespace(prefix: "soap", uri: "http://schemas.xmlsoap.org/soap/envelope/")

    public var keyDecodingStrategy: XMLDecoder.KeyDecodingStrategy {
        get { return baseDecoder.keyDecodingStrategy }
        set { baseDecoder.keyDecodingStrategy = newValue }
    }

    public init() {
        baseDecoder = XMLDecoder()
    }

    public func decode<T: Decodable>(from data: Data) throws -> T {
        return try baseDecoder.decode(SOAPBody<T>.self, from: data).contents
    }

}

