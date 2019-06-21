//
//  SOAPEncoder.swift
//  CNS
//
//  Created by ライアン on 5/23/19.
//  Copyright © 2019 Duet Health. All rights reserved.
//

import Foundation

public class SOAPEncoder {

    private let baseEncoder: XMLEncoder

    public var soapNamespace = XMLNamespace(prefix: "soap", uri: "http://schemas.xmlsoap.org/soap/envelope/")
    public var requestPayloadNamespace = XMLNamespace?.none

    public var keyEncodingStrategy: XMLEncoder.KeyEncodingStrategy {
        get { return baseEncoder.keyEncodingStrategy }
        set { baseEncoder.keyEncodingStrategy = newValue }
    }

    public init() {
        baseEncoder = XMLEncoder()
    }

    public func encode<T: Encodable>(_ value: T) throws -> Data {
        var namespaceUsages: [HashedCodingKey: XMLNamespaceUsage] = [
            HashedCodingKey(SOAPBody<T>.SOAPKeys.envelope): XMLNamespaceUsage.define(using: soapNamespace, including: requestPayloadNamespace.map { [$0] } ?? [])
        ]
        namespaceUsages[HashedCodingKey(SOAPBody<T>.SOAPKeys.body)] = XMLNamespaceUsage.use(soapNamespace)
        namespaceUsages[HashedCodingKey(SOAPBody<T>.TypeKey(T.self))] = requestPayloadNamespace.map(XMLNamespaceUsage.use)
        baseEncoder.userInfo[.xmlNamespaces] = namespaceUsages
        return try baseEncoder.encode(SOAPBody(contents: value))
    }

}

extension SOAPEncoder: RequestEncoding {

    public var contentType: MIMEType {
        return baseEncoder.contentType
    }

}


struct HashedCodingKey: Hashable {

    private let hashedValue: AnyHashable

    init(_ codingKey: CodingKey) {
        hashedValue = AnyHashable(codingKey.stringValue)
    }

}
