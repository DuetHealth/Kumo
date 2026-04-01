import Foundation
import XCTest
@testable import Kumo
@testable import KumoCoding

// All XML fixtures in this file are sanitized synthetic data.
// Structure mirrors production Atom-feed layout; identifiers are fictional.

class HeaderConfigurationDecodingTests: XCTestCase {

    // MARK: - Single Configuration (content only)

    func testDecodeSingleConfiguration() {
        let decoder = XMLDecoder()
        // Keys in XML are PascalCase and match CodingKeys exactly → useDefaultKeys
        let data = """
        <Configuration xmlns="http://example.com/Model/HeaderConfiguration">
            <Name>Orders Display</Name>
            <Demographics>
                <Controls>
                    <Control>
                        <Field><Source>Patient</Source><Attribute>Id</Attribute></Field>
                        <DataType>Text</DataType>
                        <Required>False</Required>
                        <ReadOnly>False</ReadOnly>
                        <MaximumLength>20</MaximumLength>
                    </Control>
                    <Control>
                        <Field><Source>Patient</Source><Attribute>FullName</Attribute></Field>
                        <DataType>Text</DataType>
                        <Required>False</Required>
                        <ReadOnly>False</ReadOnly>
                        <MaximumLength>350</MaximumLength>
                    </Control>
                </Controls>
            </Demographics>
            <PatientSearching>
                <Sources>
                    <Source>Patient</Source>
                    <Source>PatientVisit</Source>
                </Sources>
                <Target>Patient</Target>
                <Criteria>
                    <Criterion>
                        <Label>Last Name</Label>
                        <Type>Text</Type>
                        <Field><Source>Patient</Source><Attribute>LastName</Attribute></Field>
                    </Criterion>
                </Criteria>
                <Columns>
                    <Column>
                        <Type>Text</Type>
                        <Field><Source>Patient</Source><Attribute>FirstName</Attribute></Field>
                    </Column>
                </Columns>
            </PatientSearching>
            <ArtifactSearching>
                <Sources>
                    <Source>Order</Source>
                </Sources>
                <Target>Order</Target>
                <ReadOnlyCriteria>
                    <Criterion>
                        <Type>Text</Type>
                        <Field><Source>Patient</Source><Attribute>Id</Attribute></Field>
                    </Criterion>
                </ReadOnlyCriteria>
                <Columns>
                    <Column>
                        <Type>Text</Type>
                        <Field><Source>PatientVisit</Source><Attribute>AccountNumber</Attribute></Field>
                    </Column>
                </Columns>
            </ArtifactSearching>
        </Configuration>
        """.data(using: .utf8)!

        do {
            let config = try decoder.decode(Configuration.self, from: data)
            XCTAssertEqual(config.Name, "Orders Display")
            XCTAssertEqual(config.Demographics.Controls.count, 2)
            XCTAssertEqual(config.Demographics.Controls[0].Field.Source, "Patient")
            XCTAssertEqual(config.Demographics.Controls[0].Field.Attribute, "Id")
            XCTAssertEqual(config.Demographics.Controls[0].DataType, "Text")
            XCTAssertEqual(config.Demographics.Controls[0].MaximumLength, 20)
            XCTAssertNil(config.Demographics.Controls[0].Label)
            XCTAssertNil(config.Demographics.Controls[0].Choices)

            XCTAssertEqual(config.PatientSearching.Sources, ["Patient", "PatientVisit"])
            XCTAssertEqual(config.PatientSearching.Target, "Patient")
            XCTAssertEqual(config.PatientSearching.Criteria.count, 1)
            XCTAssertEqual(config.PatientSearching.Criteria[0].Label, "Last Name")

            XCTAssertEqual(config.ArtifactSearching.Sources, ["Order"])
            XCTAssertEqual(config.ArtifactSearching.Target, "Order")
            XCTAssertEqual(config.ArtifactSearching.ReadOnlyCriteria.count, 1)
        } catch {
            XCTFail("Decode failed: \(error)")
        }
    }

    // MARK: - Empty ReadOnlyCriteria

    func testDecodeConfigurationWithEmptyReadOnlyCriteria() {
        let decoder = XMLDecoder()
        let data = """
        <Configuration xmlns="http://example.com/Model/HeaderConfiguration">
            <Name>Test Display</Name>
            <Demographics>
                <Controls>
                    <Control>
                        <Field><Source>Patient</Source><Attribute>Id</Attribute></Field>
                        <DataType>Text</DataType>
                        <Required>False</Required>
                        <ReadOnly>False</ReadOnly>
                        <MaximumLength>20</MaximumLength>
                    </Control>
                </Controls>
            </Demographics>
            <PatientSearching>
                <Sources><Source>Patient</Source></Sources>
                <Target>Patient</Target>
                <Criteria>
                    <Criterion>
                        <Label>Last Name</Label>
                        <Type>Text</Type>
                        <Field><Source>Patient</Source><Attribute>LastName</Attribute></Field>
                    </Criterion>
                </Criteria>
                <Columns>
                    <Column>
                        <Type>Text</Type>
                        <Field><Source>Patient</Source><Attribute>FirstName</Attribute></Field>
                    </Column>
                </Columns>
            </PatientSearching>
            <ArtifactSearching>
                <Sources><Source>PatientVisit</Source></Sources>
                <Target>PatientVisit</Target>
                <ReadOnlyCriteria />
                <Columns>
                    <Column>
                        <Type>Date</Type>
                        <Field><Source>PatientVisit</Source><Attribute>AppointmentDate</Attribute></Field>
                    </Column>
                </Columns>
            </ArtifactSearching>
        </Configuration>
        """.data(using: .utf8)!

        do {
            let config = try decoder.decode(Configuration.self, from: data)
            XCTAssertEqual(config.Name, "Test Display")
            XCTAssertEqual(config.ArtifactSearching.ReadOnlyCriteria, [])
        } catch {
            XCTFail("Decode failed: \(error)")
        }
    }

    // MARK: - Empty Choices on Control

    func testDecodeControlWithEmptyChoices() {
        let decoder = XMLDecoder()
        let data = """
        <Configuration xmlns="http://example.com/Model/HeaderConfiguration">
            <Name>Choices Test</Name>
            <Demographics>
                <Controls>
                    <Control>
                        <Field><Source>PatientVisit</Source><Attribute>UserField1</Attribute></Field>
                        <DataType>Text</DataType>
                        <Required>False</Required>
                        <ReadOnly>False</ReadOnly>
                        <MaximumLength>100</MaximumLength>
                        <Choices />
                    </Control>
                </Controls>
            </Demographics>
            <PatientSearching>
                <Sources><Source>Patient</Source></Sources>
                <Target>Patient</Target>
                <Criteria>
                    <Criterion><Type>Text</Type><Field><Source>Patient</Source><Attribute>Id</Attribute></Field></Criterion>
                </Criteria>
                <Columns>
                    <Column><Type>Text</Type><Field><Source>Patient</Source><Attribute>Id</Attribute></Field></Column>
                </Columns>
            </PatientSearching>
            <ArtifactSearching>
                <Sources><Source>Order</Source></Sources>
                <Target>Order</Target>
                <ReadOnlyCriteria />
                <Columns>
                    <Column><Type>Text</Type><Field><Source>Order</Source><Attribute>OrderNumber</Attribute></Field></Column>
                </Columns>
            </ArtifactSearching>
        </Configuration>
        """.data(using: .utf8)!

        do {
            let config = try decoder.decode(Configuration.self, from: data)
            XCTAssertEqual(config.Demographics.Controls.count, 1)
            // Empty <Choices /> should decode as nil
            XCTAssertNil(config.Demographics.Controls[0].Choices)
        } catch {
            XCTFail("Decode failed: \(error)")
        }
    }

    // MARK: - Full Atom Feed Decoding

    func testDecodeFullAtomFeed() {
        let decoder = XMLDecoder()
        let data = Self.fullAtomFeedXML.data(using: .utf8)!

        do {
            let feed = try decoder.decode(HeaderConfigurationFeed.self, from: data)
            XCTAssertEqual(feed.entry.count, 2)

            let first = feed.entry[0].content.configuration
            XCTAssertEqual(first.Name, "Orders Display")
            XCTAssertEqual(first.Demographics.Controls.count, 23)

            // Verify first control
            XCTAssertEqual(first.Demographics.Controls[0].Field.Source, "Patient")
            XCTAssertEqual(first.Demographics.Controls[0].Field.Attribute, "Id")
            XCTAssertEqual(first.Demographics.Controls[0].DataType, "Text")
            XCTAssertEqual(first.Demographics.Controls[0].MaximumLength, 20)

            // Verify PatientSearching
            XCTAssertEqual(first.PatientSearching.Sources, ["Patient", "PatientVisit"])
            XCTAssertEqual(first.PatientSearching.Target, "Patient")
            XCTAssertEqual(first.PatientSearching.Criteria.count, 5)
            XCTAssertEqual(first.PatientSearching.Criteria[0].Label, "Last Name")
            XCTAssertEqual(first.PatientSearching.Columns.count, 8)

            // Verify ArtifactSearching — has ReadOnlyCriteria
            XCTAssertEqual(first.ArtifactSearching.Sources, ["Order"])
            XCTAssertEqual(first.ArtifactSearching.Target, "Order")
            XCTAssertEqual(first.ArtifactSearching.ReadOnlyCriteria.count, 6)
            XCTAssertEqual(first.ArtifactSearching.Columns.count, 8)

            let second = feed.entry[1].content.configuration
            XCTAssertEqual(second.Name, "Test Display")
            XCTAssertEqual(second.Demographics.Controls.count, 23)

            // Second entry has empty ReadOnlyCriteria
            XCTAssertEqual(second.ArtifactSearching.ReadOnlyCriteria, [])
            XCTAssertEqual(second.ArtifactSearching.Columns.count, 15)

            // Verify a criterion without Label
            let criterion = first.PatientSearching.Criteria[2]  // Birthdate — no Label
            XCTAssertNil(criterion.Label)
            XCTAssertEqual(criterion.Type, "Date")
            XCTAssertEqual(criterion.Field.Attribute, "Birthdate")

            // Verify a column with Label
            let labeledColumn = first.PatientSearching.Columns[6]  // Age
            XCTAssertEqual(labeledColumn.Label, "Age")

            // Verify last control is read-only
            let lastControl = first.Demographics.Controls[22]
            XCTAssertEqual(lastControl.ReadOnly, "True")
            XCTAssertEqual(lastControl.Field.Attribute, "AdmittingPhysician")
        } catch {
            XCTFail("Decode failed: \(error)")
        }
    }

    // MARK: - Full XML Fixture (sanitized)

    // Synthetic Atom feed that mirrors production structure.
    // All URLs, client IDs, author names, and identifiers are fictional.
    static let fullAtomFeedXML = """
    <?xml version="1.0" encoding="utf-8"?><feed xmlns="http://www.w3.org/2005/Atom"><id>http://atom.example.com/Client/00000/HeaderConfigurations</id><title>Header Configurations</title><updated>2025-01-01T00:00:00-00:00</updated><author><name>TestUser</name></author><entry><id>http://atom.example.com/Client/00000/HeaderConfiguration/1001</id><title>Header Configuration</title><updated>2025-01-01T00:00:00-00:00</updated><author><name>TestUser</name></author><link rel="alternate" href="https://test.example.com/sync/Client/00000/HeaderConfiguration/1001" /><content type="text/xml"><Configuration xmlns="http://example.com/Model/HeaderConfiguration"><Name>Orders Display</Name><Demographics><Controls><Control><Field><Source>Patient</Source><Attribute>Id</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>20</MaximumLength></Control><Control><Field><Source>Patient</Source><Attribute>FullName</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>350</MaximumLength></Control><Control><Field><Source>Patient</Source><Attribute>Gender</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>1</MaximumLength></Control><Control><Field><Source>Patient</Source><Attribute>Birthdate</Attribute></Field><DataType>Date</DataType><Required>False</Required><ReadOnly>False</ReadOnly></Control><Control><Field><Source>PatientVisit</Source><Attribute>OrderNumber</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>50</MaximumLength></Control><Control><Field><Source>PatientVisit</Source><Attribute>AccountNumber</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>50</MaximumLength></Control><Control><Field><Source>PatientVisit</Source><Attribute>AppointmentDate</Attribute></Field><DataType>Date</DataType><Required>False</Required><ReadOnly>False</ReadOnly></Control><Control><Field><Source>PatientVisit</Source><Attribute>AppointmentTime</Attribute></Field><DataType>Time</DataType><Required>False</Required><ReadOnly>False</ReadOnly></Control><Control><Field><Source>Header</Source><Attribute>DateDictated</Attribute></Field><DataType>Moment</DataType><Required>False</Required><ReadOnly>False</ReadOnly></Control><Control><Field><Source>PatientVisit</Source><Attribute>AdmissionDate</Attribute></Field><DataType>Moment</DataType><Required>False</Required><ReadOnly>False</ReadOnly></Control><Control><Field><Source>PatientVisit</Source><Attribute>DischargeDate</Attribute></Field><DataType>Moment</DataType><Required>False</Required><ReadOnly>False</ReadOnly></Control><Control><Field><Source>Header</Source><Attribute>Author</Attribute></Field><DataType>Uri</DataType><Required>False</Required><ReadOnly>False</ReadOnly></Control><Control><Field><Source>Header</Source><Attribute>DocumentType</Attribute></Field><DataType>Uri</DataType><Required>False</Required><ReadOnly>False</ReadOnly></Control><Control><Field><Source>Header</Source><Attribute>Location</Attribute></Field><DataType>Uri</DataType><Required>False</Required><ReadOnly>False</ReadOnly></Control><Control><Field><Source>Header</Source><Attribute>PatientLetter</Attribute></Field><DataType>Uri</DataType><Required>False</Required><ReadOnly>False</ReadOnly></Control><Control><Field><Source>PatientVisit</Source><Attribute>UserField1</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>100</MaximumLength><Choices /></Control><Control><Field><Source>PatientVisit</Source><Attribute>UserField2</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>100</MaximumLength><Choices /></Control><Control><Field><Source>PatientVisit</Source><Attribute>UserField3</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>100</MaximumLength><Choices /></Control><Control><Field><Source>PatientVisit</Source><Attribute>UserField4</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>100</MaximumLength><Choices /></Control><Control><Field><Source>PatientVisit</Source><Attribute>UserField5</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>100</MaximumLength><Choices /></Control><Control><Field><Source>PatientVisit</Source><Attribute>Bed</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>20</MaximumLength></Control><Control><Field><Source>PatientVisit</Source><Attribute>Floor</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>20</MaximumLength></Control><Control><Field><Source>PatientVisit</Source><Attribute>AdmittingPhysician</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>True</ReadOnly></Control></Controls></Demographics><PatientSearching><Sources><Source>Patient</Source><Source>PatientVisit</Source></Sources><Target>Patient</Target><Criteria><Criterion><Label>Last Name</Label><Type>Text</Type><Field><Source>Patient</Source><Attribute>LastName</Attribute></Field></Criterion><Criterion><Label>First Name</Label><Type>Text</Type><Field><Source>Patient</Source><Attribute>FirstName</Attribute></Field></Criterion><Criterion><Type>Date</Type><Field><Source>Patient</Source><Attribute>Birthdate</Attribute></Field></Criterion><Criterion><Type>Text</Type><Field><Source>Patient</Source><Attribute>Id</Attribute></Field></Criterion><Criterion><Label>Age</Label><Type>Text</Type><Field><Source>PatientVisit</Source><Attribute>PatientAge</Attribute></Field></Criterion></Criteria><Columns><Column><Type>Text</Type><Field><Source>Patient</Source><Attribute>FirstName</Attribute></Field></Column><Column><Type>Text</Type><Field><Source>Patient</Source><Attribute>LastName</Attribute></Field></Column><Column><Type>Text</Type><Field><Source>Patient</Source><Attribute>Gender</Attribute></Field></Column><Column><Type>Date</Type><Field><Source>Patient</Source><Attribute>Birthdate</Attribute></Field></Column><Column><Type>Date</Type><Field><Source>Patient</Source><Attribute>AppointmentDate</Attribute></Field></Column><Column><Type>Text</Type><Field><Source>Patient</Source><Attribute>Id</Attribute></Field></Column><Column><Label>Age</Label><Type>Text</Type><Field><Source>PatientVisit</Source><Attribute>PatientAge</Attribute></Field></Column><Column><Label>Location</Label><Type>Text</Type><Field><Source>PatientVisit</Source><Attribute>ClientLocationName</Attribute></Field></Column></Columns></PatientSearching><ArtifactSearching><Sources><Source>Order</Source></Sources><Target>Order</Target><ReadOnlyCriteria><Criterion><Type>Text</Type><Field><Source>Patient</Source><Attribute>Id</Attribute></Field></Criterion><Criterion><Type>Text</Type><Field><Source>Patient</Source><Attribute>FullName</Attribute></Field></Criterion><Criterion><Type>Date</Type><Field><Source>Patient</Source><Attribute>Birthdate</Attribute></Field></Criterion><Criterion><Type>Text</Type><Field><Source>Patient</Source><Attribute>Gender</Attribute></Field></Criterion><Criterion><Type>Text</Type><Field><Source>Patient</Source><Attribute>FirstName</Attribute></Field></Criterion><Criterion><Type>Text</Type><Field><Source>Patient</Source><Attribute>LastName</Attribute></Field></Criterion></ReadOnlyCriteria><Columns><Column><Type>Text</Type><Field><Source>PatientVisit</Source><Attribute>AccountNumber</Attribute></Field></Column><Column><Type>Moment</Type><Field><Source>PatientVisit</Source><Attribute>AdmissionDate</Attribute></Field></Column><Column><Type>Text</Type><Field><Source>Order</Source><Attribute>OrderNumber</Attribute></Field></Column><Column><Type>Text</Type><Field><Source>Order</Source><Attribute>AccessionNumber</Attribute></Field></Column><Column><Type>Text</Type><Field><Source>Order</Source><Attribute>OrderStatus</Attribute></Field></Column><Column><Type>Date</Type><Field><Source>Order</Source><Attribute>DateObserved</Attribute></Field></Column><Column><Type>Text</Type><Field><Source>Order</Source><Attribute>Description</Attribute></Field></Column><Column><Type>Text</Type><Field><Source>Order</Source><Attribute>OrderingPhysician</Attribute></Field></Column></Columns></ArtifactSearching></Configuration></content></entry><entry><id>http://atom.example.com/Client/00000/HeaderConfiguration/1002</id><title>Header Configuration</title><updated>2025-01-01T00:00:00-00:00</updated><author><name>TestUser</name></author><link rel="alternate" href="https://test.example.com/sync/Client/00000/HeaderConfiguration/1002" /><content type="text/xml"><Configuration xmlns="http://example.com/Model/HeaderConfiguration"><Name>Test Display</Name><Demographics><Controls><Control><Field><Source>Patient</Source><Attribute>Id</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>20</MaximumLength></Control><Control><Field><Source>Patient</Source><Attribute>FullName</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>350</MaximumLength></Control><Control><Field><Source>Patient</Source><Attribute>Gender</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>1</MaximumLength></Control><Control><Field><Source>Patient</Source><Attribute>Birthdate</Attribute></Field><DataType>Date</DataType><Required>False</Required><ReadOnly>False</ReadOnly></Control><Control><Field><Source>PatientVisit</Source><Attribute>AppointmentDate</Attribute></Field><DataType>Date</DataType><Required>False</Required><ReadOnly>False</ReadOnly></Control><Control><Field><Source>PatientVisit</Source><Attribute>AppointmentTime</Attribute></Field><DataType>Time</DataType><Required>False</Required><ReadOnly>False</ReadOnly></Control><Control><Field><Source>Header</Source><Attribute>DateDictated</Attribute></Field><DataType>Moment</DataType><Required>False</Required><ReadOnly>False</ReadOnly></Control><Control><Field><Source>PatientVisit</Source><Attribute>AdmissionDate</Attribute></Field><DataType>Moment</DataType><Required>False</Required><ReadOnly>False</ReadOnly></Control><Control><Field><Source>PatientVisit</Source><Attribute>DischargeDate</Attribute></Field><DataType>Moment</DataType><Required>False</Required><ReadOnly>False</ReadOnly></Control><Control><Field><Source>PatientVisit</Source><Attribute>OrderNumber</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>50</MaximumLength></Control><Control><Field><Source>Header</Source><Attribute>Author</Attribute></Field><DataType>Uri</DataType><Required>False</Required><ReadOnly>False</ReadOnly></Control><Control><Field><Source>Header</Source><Attribute>DocumentType</Attribute></Field><DataType>Uri</DataType><Required>False</Required><ReadOnly>False</ReadOnly></Control><Control><Field><Source>Header</Source><Attribute>Location</Attribute></Field><DataType>Uri</DataType><Required>False</Required><ReadOnly>False</ReadOnly></Control><Control><Field><Source>Header</Source><Attribute>PatientLetter</Attribute></Field><DataType>Uri</DataType><Required>False</Required><ReadOnly>False</ReadOnly></Control><Control><Field><Source>PatientVisit</Source><Attribute>UserField1</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>100</MaximumLength><Choices /></Control><Control><Field><Source>PatientVisit</Source><Attribute>UserField2</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>100</MaximumLength><Choices /></Control><Control><Field><Source>PatientVisit</Source><Attribute>UserField3</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>100</MaximumLength><Choices /></Control><Control><Field><Source>PatientVisit</Source><Attribute>UserField4</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>100</MaximumLength><Choices /></Control><Control><Field><Source>PatientVisit</Source><Attribute>UserField5</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>100</MaximumLength><Choices /></Control><Control><Field><Source>PatientVisit</Source><Attribute>Bed</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>20</MaximumLength></Control><Control><Field><Source>PatientVisit</Source><Attribute>AccountNumber</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>50</MaximumLength></Control><Control><Field><Source>PatientVisit</Source><Attribute>Floor</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>20</MaximumLength></Control><Control><Field><Source>PatientVisit</Source><Attribute>AdmittingPhysician</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>True</ReadOnly></Control></Controls></Demographics><PatientSearching><Sources><Source>Patient</Source><Source>PatientVisit</Source></Sources><Target>Patient</Target><Criteria><Criterion><Label>Last Name</Label><Type>Text</Type><Field><Source>Patient</Source><Attribute>LastName</Attribute></Field></Criterion><Criterion><Label>First Name</Label><Type>Text</Type><Field><Source>Patient</Source><Attribute>FirstName</Attribute></Field></Criterion><Criterion><Type>Date</Type><Field><Source>Patient</Source><Attribute>Birthdate</Attribute></Field></Criterion><Criterion><Type>Text</Type><Field><Source>Patient</Source><Attribute>Id</Attribute></Field></Criterion><Criterion><Label>Age</Label><Type>Text</Type><Field><Source>PatientVisit</Source><Attribute>PatientAge</Attribute></Field></Criterion></Criteria><Columns><Column><Type>Text</Type><Field><Source>Patient</Source><Attribute>FirstName</Attribute></Field></Column><Column><Type>Text</Type><Field><Source>Patient</Source><Attribute>LastName</Attribute></Field></Column><Column><Type>Text</Type><Field><Source>Patient</Source><Attribute>Gender</Attribute></Field></Column><Column><Type>Date</Type><Field><Source>Patient</Source><Attribute>Birthdate</Attribute></Field></Column><Column><Type>Date</Type><Field><Source>Patient</Source><Attribute>AppointmentDate</Attribute></Field></Column><Column><Type>Text</Type><Field><Source>Patient</Source><Attribute>Id</Attribute></Field></Column><Column><Label>Age</Label><Type>Text</Type><Field><Source>PatientVisit</Source><Attribute>PatientAge</Attribute></Field></Column><Column><Label>Location</Label><Type>Text</Type><Field><Source>PatientVisit</Source><Attribute>ClientLocationName</Attribute></Field></Column></Columns></PatientSearching><ArtifactSearching><Sources><Source>PatientVisit</Source></Sources><Target>PatientVisit</Target><ReadOnlyCriteria /><Columns><Column><Type>Date</Type><Field><Source>PatientVisit</Source><Attribute>AppointmentDate</Attribute></Field></Column><Column><Type>Time</Type><Field><Source>PatientVisit</Source><Attribute>AppointmentTime</Attribute></Field></Column><Column><Label>Description</Label><Type>Text</Type><Field><Source>PatientVisit</Source><Attribute>Description</Attribute></Field></Column><Column><Type>Text</Type><Field><Source>Patient</Source><Attribute>Id</Attribute></Field></Column><Column><Type>Text</Type><Field><Source>Patient</Source><Attribute>FullName</Attribute></Field></Column><Column><Type>Text</Type><Field><Source>Patient</Source><Attribute>Gender</Attribute></Field></Column><Column><Type>Date</Type><Field><Source>Patient</Source><Attribute>Birthdate</Attribute></Field></Column><Column><Label>Location ID</Label><Type>Text</Type><Field><Source>PatientVisit</Source><Attribute>ClientLocationId</Attribute></Field></Column><Column><Label>Location Name</Label><Type>Text</Type><Field><Source>PatientVisit</Source><Attribute>ClientLocationName</Attribute></Field></Column><Column><Type>Text</Type><Field><Source>PatientVisit</Source><Attribute>OrderNumber</Attribute></Field></Column><Column><Type>Text</Type><Field><Source>PatientVisit</Source><Attribute>UserField1</Attribute></Field></Column><Column><Type>Text</Type><Field><Source>PatientVisit</Source><Attribute>UserField2</Attribute></Field></Column><Column><Type>Text</Type><Field><Source>PatientVisit</Source><Attribute>UserField3</Attribute></Field></Column><Column><Type>Text</Type><Field><Source>PatientVisit</Source><Attribute>UserField4</Attribute></Field></Column><Column><Type>Text</Type><Field><Source>PatientVisit</Source><Attribute>UserField5</Attribute></Field></Column></Columns></ArtifactSearching></Configuration></content></entry></feed>
    """
}
