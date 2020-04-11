import Foundation
import XCTest
@testable import Kumo
@testable import KumoCoding

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
            <?xml version="1.0"?><soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope/"><soap:Body><m:GetPriceRequest xmlns:m="https://www.w3schools.com/prices"><m:Name>iPhone Excess to the Max</m:Name><m:Sku><m:Value>00124230128212398-6</m:Value></m:Sku><m:Availability><m:IsAvailable>true</m:IsAvailable><m:Stock>100</m:Stock></m:Availability><m:Price><m:Amount>1.9</m:Amount><m:Units>Dollars</m:Units><m:Discount>0.15</m:Discount></m:Price></m:GetPriceRequest></soap:Body></soap:Envelope>
            """.data(using: .utf8)!
            print(String(data: data, encoding: .utf8)!)
            XCTAssertTrue(data == expected)
        } catch { XCTFail(error.localizedDescription) }
    }

    func testEncodingEpicAuthenticationRequest() {
        let encoder = XMLEncoder()
        encoder.keyEncodingStrategy = .convertToPascalCase
        encoder.userInfo[.rootNamespace] = XMLNamespace(prefix: "", uri: "urn:Epic-com:MyChartMobile.2010.Services")
        let request = Authenticate(username: "Username", password: "Password", deviceID: "E31A21DE-1167-45D3-8845-FD5F65AA5E4C", appID: "com.advocate.myadvocate.tst-iPhone")
        do {
            let data = try encoder.encode(request)
            let expected = """
            <?xml version="1.0"?><Authenticate xmlns="urn:Epic-com:MyChartMobile.2010.Services"><Username>Username</Username><Password>Password</Password><DeviceID>E31A21DE-1167-45D3-8845-FD5F65AA5E4C</DeviceID><AppID>com.advocate.myadvocate.tst-iPhone</AppID></Authenticate>
            """.data(using: .utf8)!
            XCTAssertTrue(data == expected)
        } catch { XCTFail(error.localizedDescription) }
    }

    func testEncodingSimpleLists() {
        let encoder = XMLEncoder()
        encoder.keyEncodingStrategy = .convertToPascalCase
        encoder.userInfo[.rootNamespace] = XMLNamespace(prefix: "", uri: "urn:xml.is.bad")
        encoder.addElementNameForList(elementName: "Element", list: "SimpleList")
        let listContainer = ListContainer(simpleList: ["car", "cdr", "cons"])
        do {
            let data = try encoder.encode(listContainer)
            let foo = String(data: data, encoding: .utf8)!
            let expected = """
            <?xml version="1.0"?><ListContainer xmlns="urn:xml.is.bad"><SimpleList><Element>car</Element><Element>cdr</Element><Element>cons</Element></SimpleList></ListContainer>
            """.data(using: .utf8)!
            XCTAssertTrue(data == expected)
        } catch { XCTFail(error.localizedDescription) }
    }

    func testEncodingComplexLists() {
        let encoder = XMLEncoder()
        encoder.keyEncodingStrategy = .convertToPascalCase
        encoder.userInfo[.rootNamespace] = XMLNamespace(prefix: "", uri: "urn:xml.is.bad")
        encoder.addElementNameForList(elementName: "ComplexElement", list: "ComplexList")
        let listContainer = ComplexListContainer(complexList: [.init(x: "x", y: "y")])
        do {
            let data = try encoder.encode(listContainer)
            let expected = """
            <?xml version="1.0"?><ComplexListContainer xmlns="urn:xml.is.bad"><ComplexList><ComplexElement><X>x</X><Y>y</Y></ComplexElement></ComplexList></ComplexListContainer>
            """.data(using: .utf8)!
            XCTAssertTrue(data == expected)
        } catch { XCTFail(error.localizedDescription) }
    }

}
