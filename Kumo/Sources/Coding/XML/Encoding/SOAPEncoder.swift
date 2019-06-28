import Foundation

public class SOAPEncoder {

    
    private let baseEncoder: XMLEncoder

    public var soapNamespaceUsage = XMLNamespaceUsage.define(using: XMLNamespace(prefix: "soap", uri: "http://schemas.xmlsoap.org/soap/envelope/"), including: [])
    public var requestPayloadNamespaceUsage = XMLNamespaceUsage?.none

    public var keyEncodingStrategy: XMLEncoder.KeyEncodingStrategy {
        get { return baseEncoder.keyEncodingStrategy }
        set { baseEncoder.keyEncodingStrategy = newValue }
    }

    public init() {
        baseEncoder = XMLEncoder()
    }

    public func encode<T: Encodable>(_ value: T) throws -> Data {
        var namespaceUsages: [HashedCodingKey: XMLNamespaceUsage] = [
            HashedCodingKey(SOAPBody<T>.SOAPKeys.envelope): soapNamespaceUsage
        ]
        namespaceUsages[HashedCodingKey(SOAPBody<T>.SOAPKeys.body)] = XMLNamespaceUsage.use(soapNamespaceUsage.namespace)
        namespaceUsages[HashedCodingKey(SOAPBody<T>.TypeKey(T.self))] = requestPayloadNamespaceUsage
        baseEncoder.userInfo[.xmlNamespaces] = namespaceUsages
        return try baseEncoder.encode(SOAPBody(contents: value))
    }

}

extension SOAPEncoder: RequestEncoding {

    public var contentType: MIMEType {
        return baseEncoder.contentType
    }

}
