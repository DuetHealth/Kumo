//
//  XMLDecodingTests.swift
//  CNSTests
//
//  Created by ライアン on 5/22/19.
//  Copyright © 2019 Duet Health. All rights reserved.
//

import Foundation
import XCTest
@testable import CNS

struct GetPriceResponse: Decodable, Equatable {
    struct Price: Decodable, Equatable {
        let amount: Double
        let units: String
    }
    let price: Price
    let discount: Double
}

class XMLDecodingTests: XCTestCase {

    func testDecodingSOAPRequest() {
        let decoder = SOAPDecoder()
        decoder.keyDecodingStrategy = .convertFromPascalCase
        let data = """
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
        do {
            let response: GetPriceResponse = try decoder.decode(from: data)
            let expected = GetPriceResponse(price: GetPriceResponse.Price(amount: 1.9, units: "Dollars"), discount: 0.15)
            XCTAssertTrue(response == expected)
        } catch { XCTFail(error.localizedDescription) }
    }

}
