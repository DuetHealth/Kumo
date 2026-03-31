import Foundation
import XCTest
@testable import Kumo
@testable import KumoCoding

/// Tests that verify XMLEncoder and XMLDecoder work together for common
/// XML patterns: flat structures, nested objects, SOAP envelopes, and
/// PascalCase key conversion — the typical patterns used by enterprise
/// healthcare XML services.
class XMLRoundtripTests: XCTestCase {

    // MARK: - Models (generic, not tied to any specific vendor)

    struct PatientRecord: Codable, Equatable {
        let recordId: String
        let firstName: String
        let lastName: String
        let dateOfBirth: String
        let gender: String
    }

    struct Appointment: Codable, Equatable {
        let appointmentId: String
        let recordId: String
        let provider: String
        let dateTime: String
        let status: String
    }

    struct ResponseEnvelope: Codable, Equatable {
        let statusCode: String
        let message: String
        let patient: PatientRecord
    }

    // MARK: - Plain XML Encode → Decode Roundtrip

    func testFlatStructureRoundtrip() {
        let encoder = XMLEncoder()
        encoder.keyEncodingStrategy = .convertToPascalCase
        encoder.userInfo[.rootNamespace] = XMLNamespace(prefix: "", uri: "urn:test:record:v1")

        let decoder = XMLDecoder()
        decoder.keyDecodingStrategy = .convertFromPascalCase

        let original = PatientRecord(
            recordId: "R12345",
            firstName: "Jane",
            lastName: "Smith",
            dateOfBirth: "1985-12-25",
            gender: "F"
        )

        do {
            let data = try encoder.encode(original)
            let decoded = try decoder.decode(PatientRecord.self, from: data)
            XCTAssertEqual(original, decoded)
        } catch {
            XCTFail("Flat structure roundtrip failed: \(error)")
        }
    }

    func testNestedStructureRoundtrip() {
        let encoder = XMLEncoder()
        encoder.keyEncodingStrategy = .convertToPascalCase
        encoder.userInfo[.rootNamespace] = XMLNamespace(prefix: "", uri: "urn:test:response:v1")

        let decoder = XMLDecoder()
        decoder.keyDecodingStrategy = .convertFromPascalCase

        let original = ResponseEnvelope(
            statusCode: "200",
            message: "OK",
            patient: PatientRecord(
                recordId: "R99999",
                firstName: "John",
                lastName: "Doe",
                dateOfBirth: "1990-01-15",
                gender: "M"
            )
        )

        do {
            let data = try encoder.encode(original)
            let decoded = try decoder.decode(ResponseEnvelope.self, from: data)
            XCTAssertEqual(original, decoded)
        } catch {
            XCTFail("Nested structure roundtrip failed: \(error)")
        }
    }

    // MARK: - Plain XML Decoding (no SOAP)

    func testDecodingFlatXML() {
        let decoder = XMLDecoder()
        decoder.keyDecodingStrategy = .convertFromPascalCase

        let xml = """
        <PatientRecord xmlns="urn:test:record:v1">
            <RecordId>R12345</RecordId>
            <FirstName>Jane</FirstName>
            <LastName>Smith</LastName>
            <DateOfBirth>1985-12-25</DateOfBirth>
            <Gender>F</Gender>
        </PatientRecord>
        """.data(using: .utf8)!

        do {
            let record = try decoder.decode(PatientRecord.self, from: xml)
            XCTAssertEqual(record.recordId, "R12345")
            XCTAssertEqual(record.firstName, "Jane")
            XCTAssertEqual(record.lastName, "Smith")
            XCTAssertEqual(record.dateOfBirth, "1985-12-25")
            XCTAssertEqual(record.gender, "F")
        } catch {
            XCTFail("Flat XML decoding failed: \(error)")
        }
    }

    func testDecodingNestedXML() {
        let decoder = XMLDecoder()
        decoder.keyDecodingStrategy = .convertFromPascalCase

        let xml = """
        <ResponseEnvelope xmlns="urn:test:response:v1">
            <StatusCode>200</StatusCode>
            <Message>OK</Message>
            <Patient>
                <RecordId>R12345</RecordId>
                <FirstName>Jane</FirstName>
                <LastName>Smith</LastName>
                <DateOfBirth>1985-12-25</DateOfBirth>
                <Gender>F</Gender>
            </Patient>
        </ResponseEnvelope>
        """.data(using: .utf8)!

        do {
            let response = try decoder.decode(ResponseEnvelope.self, from: xml)
            XCTAssertEqual(response.statusCode, "200")
            XCTAssertEqual(response.message, "OK")
            XCTAssertEqual(response.patient.recordId, "R12345")
            XCTAssertEqual(response.patient.firstName, "Jane")
        } catch {
            XCTFail("Nested XML decoding failed: \(error)")
        }
    }

    // MARK: - SOAP Roundtrip

    func testSOAPRoundtrip() {
        let encoder = SOAPEncoder()
        encoder.keyEncodingStrategy = .convertToPascalCase
        encoder.soapNamespaceUsage = .define(
            using: XMLNamespace(prefix: "soap", uri: "http://www.w3.org/2003/05/soap-envelope/"),
            including: []
        )
        encoder.requestPayloadNamespaceUsage = .defineBeneath(
            XMLNamespace(prefix: "ns", uri: "urn:test:record:v1")
        )

        let original = PatientRecord(
            recordId: "R77777",
            firstName: "Alice",
            lastName: "Wong",
            dateOfBirth: "2000-06-15",
            gender: "F"
        )

        do {
            let data = try encoder.encode(original)
            let xmlString = String(data: data, encoding: .utf8)!

            // Verify SOAP structure
            XCTAssertTrue(xmlString.contains("soap:Envelope"))
            XCTAssertTrue(xmlString.contains("soap:Body"))
            XCTAssertTrue(xmlString.contains("ns:PatientRecord"))
            XCTAssertTrue(xmlString.contains("ns:RecordId"))
            XCTAssertTrue(xmlString.contains(">R77777<"))

            // Decode back via SOAPDecoder
            let decoder = SOAPDecoder()
            decoder.keyDecodingStrategy = .convertFromPascalCase
            let decoded: PatientRecord = try decoder.decode(from: data)
            XCTAssertEqual(original, decoded)
        } catch {
            XCTFail("SOAP roundtrip failed: \(error)")
        }
    }

    // MARK: - Encoding Verification

    func testEncodingProducesExpectedXML() {
        let encoder = XMLEncoder()
        encoder.keyEncodingStrategy = .convertToPascalCase
        encoder.userInfo[.rootNamespace] = XMLNamespace(prefix: "", uri: "urn:test:appt:v1")

        let appointment = Appointment(
            appointmentId: "A001",
            recordId: "R12345",
            provider: "Dr. Smith",
            dateTime: "2026-04-01T10:30:00",
            status: "Confirmed"
        )

        do {
            let data = try encoder.encode(appointment)
            let xml = String(data: data, encoding: .utf8)!
            XCTAssertTrue(xml.contains("<AppointmentId>A001</AppointmentId>"))
            XCTAssertTrue(xml.contains("<RecordId>R12345</RecordId>"))
            XCTAssertTrue(xml.contains("<Provider>Dr. Smith</Provider>"))
            XCTAssertTrue(xml.contains("<DateTime>2026-04-01T10:30:00</DateTime>"))
            XCTAssertTrue(xml.contains("<Status>Confirmed</Status>"))
            XCTAssertTrue(xml.contains("xmlns=\"urn:test:appt:v1\""))
        } catch {
            XCTFail("Encoding failed: \(error)")
        }
    }
}
