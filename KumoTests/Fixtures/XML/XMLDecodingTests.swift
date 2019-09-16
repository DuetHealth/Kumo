import Foundation
import XCTest
@testable import Kumo

class XMLDecodingTests: XCTestCase {

    func testDecodingSimpleSOAPRequest() {
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

    func testDecodingEpicAuthenticationRequest() {
        let decoder = XMLDecoder()
        decoder.keyDecodingStrategy = .convertFromPascalCase
        let data = """
        <Authenticate xmlns="urn:Epic-com:MyChartMobile.2010.Services">
            <Username>Username</Username>
            <Password>Password</Password>
            <DeviceID>E31A21DE-1167-45D3-8845-FD5F65AA5E4C</DeviceID>
            <AppID>com.advocate.myadvocate.tst-iPhone</AppID>
        </Authenticate>
        """.data(using: .utf8)!
        do {
            let response: Authenticate = try decoder.decode(Authenticate.self, from: data)
            let expected = Authenticate(username: "Username", password: "Password", deviceID: "E31A21DE-1167-45D3-8845-FD5F65AA5E4C", appID: "com.advocate.myadvocate.tst-iPhone")
            XCTAssertTrue(response == expected)
        } catch { XCTFail(error.localizedDescription) }
    }

}
