//
//  XMLEncodingTests.swift
//  CNSTests
//
//  Created by ライアン on 6/17/19.
//  Copyright © 2019 Duet Health. All rights reserved.
//

import Foundation
import XCTest
@testable import CNS

struct SimpleRequest: Encodable, Equatable {
    let name: String
}

struct GetPriceRequest: Encodable, Equatable {

    struct SKU: Encodable, Equatable {
        let value: String
    }

    struct Availability: Encodable, Equatable {
        let isAvailable: Bool
        let stock: UInt
    }

    struct Price: Encodable, Equatable {
        let amount: Double
        let units: String
        let discount: Double
    }

    let name: String
    let sku: SKU
    let availability: Availability
    let price: Price
    
}

class XMLEncodingTests: XCTestCase {

    func testEncodingSimpleSOAPRequest() {
        let encoder = SOAPEncoder()
        encoder.keyEncodingStrategy = .convertToPascalCase
        encoder.soapNamespaceUsage = .define(using: XMLNamespace(prefix: "soap", uri: "http://www.w3.org/2003/05/soap-envelope/"), including: [])
        encoder.requestPayloadNamespaceUsage = .defineBeneath(XMLNamespace(prefix: "m", uri: "https://www.w3schools.com/prices"))
        let request = SimpleRequest(name: "Foobar")
        do {
            let data = try encoder.encode(request)
            let expected = """
            <?xml version="1.0"?><soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope/"><soap:Body><m:SimpleRequest xmlns:m="https://www.w3schools.com/prices"><m:Name>Foobar</m:Name></m:SimpleRequest></soap:Body></soap:Envelope>
            """.data(using: .utf8)!
            XCTAssertTrue(data == expected)
        } catch { XCTFail(error.localizedDescription) }
    }

    func testEncodingDeeplyNestedSOAPRequest() {
        let encoder = SOAPEncoder()
        encoder.keyEncodingStrategy = .convertToPascalCase
        encoder.soapNamespaceUsage = .define(using: XMLNamespace(prefix: "soap", uri: "http://www.w3.org/2003/05/soap-envelope/"), including: [])
        encoder.requestPayloadNamespaceUsage = .defineBeneath(XMLNamespace(prefix: "m", uri: "https://www.w3schools.com/prices"))
        let request = GetPriceRequest(name: "iPhone Excess to the Max", sku: GetPriceRequest.SKU(value: "00124230128212398-6"), availability: GetPriceRequest.Availability(isAvailable: true, stock: 100), price: GetPriceRequest.Price(amount: 1.9, units: "Dollars", discount: 0.15))
        do {
            let data = try encoder.encode(request)
            let expected = """
            <?xml version="1.0"?><soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope/"><soap:Body><m:GetPriceResponse xmlns:m="https://www.w3schools.com/prices"><m:Sku><m:Value>00124230128212398-6</m:Value></m:Sku><m:Availability><m:IsAvailable>true</m:IsAvailable><m:Stock>100</m:Stock></m:Availability><m:Price><m:Amount>1.9</m:Amount><m:Units>Dollars</m:Units><m:Discount>0.15</m:Discount></m:Price></m:GetPriceResponse></soap:Body></soap:Envelope>
            """.data(using: .utf8)!
            print(String(data: data, encoding: .utf8)!)
            XCTAssertTrue(data == expected)
        } catch { XCTFail(error.localizedDescription) }
    }

}
