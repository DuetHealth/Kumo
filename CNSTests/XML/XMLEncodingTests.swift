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

    let name: String
    let sku: SKU
    let availability: Availability

}

class XMLEncodingTests: XCTestCase {

    func testEncodingSimpleSOAPRequest() {
        let encoder = SOAPEncoder()
        encoder.keyEncodingStrategy = .convertToPascalCase
        let request = SimpleRequest(name: "Foobar")
        do {
            let data = try encoder.encode(request)
            let expected = """
            <?xml version="1.0"?>
            <soap:Envelope
            xmlns:soap="http://www.w3.org/2003/05/soap-envelope/"
            soap:encodingStyle="http://www.w3.org/2003/05/soap-encoding">
                <soap:Body>
                    <m:SimpleRequest xmlns:m="https://www.w3schools.com/prices">
                        <m:Name>0.15</m:Name>
                    </m:SimpleRequest>
                </soap:Body>
            </soap:Envelope>
            """.data(using: .utf8)!
            XCTAssertTrue(data == expected)
        } catch { XCTFail(error.localizedDescription) }
    }

    func testEncodingDeeplyNestedSOAPRequest() {
        let encoder = SOAPEncoder()
        encoder.keyEncodingStrategy = .convertToPascalCase
        let request = GetPriceRequest(name: "iPhone Excess to the Max", sku: GetPriceRequest.SKU(value: "00124230128212398-6"), availability: GetPriceRequest.Availability(isAvailable: true, stock: 100))
        do {
            let data = try encoder.encode(request)
            let expected = """
            <?xml version="1.0"?>
            <soap:Envelope
            xmlns:soap="http://www.w3.org/2003/05/soap-envelope/"
            soap:encodingStyle="http://www.w3.org/2003/05/soap-encoding">
                <soap:Body>
                    <m:GetPriceResponse xmlns:m="https://www.w3schools.com/prices">
                        <m:Price>
                            <m:Amount>1.90</m:Amount>
                            <m:Units>Dollars</m:Units>
                        </m:Price>
                        <m:Discount>0.15</m:Discount>
                    </m:GetPriceResponse>
                </soap:Body>
            </soap:Envelope>
            """.data(using: .utf8)!
            XCTAssertTrue(data == expected)
        } catch { XCTFail(error.localizedDescription) }
    }

}
