//
//  SOAPDecoder.swift
//  CNS
//
//  Created by ライアン on 5/23/19.
//  Copyright © 2019 Duet Health. All rights reserved.
//

import Foundation

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

extension SOAPDecoder: RequestDecoding {

    public var acceptType: MIMEType {
        return baseDecoder.acceptType
    }

    public func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        return (try self.decode(from: data) as SOAPBody<T>).contents
    }

}
