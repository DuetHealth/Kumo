import Foundation
import XCTest
@testable import Kumo
@testable import KumoCoding

// All XML fixtures in this file are synthetic test data.
// The domain (inventory / catalog) is fictional and used solely to
// exercise KumoCoding's XMLDecoder against nested, mixed-content XML.

class HeaderConfigurationDecodingTests: XCTestCase {

    // MARK: - Single Configuration (content only)

    func testDecodeSingleConfiguration() {
        let decoder = XMLDecoder()
        let data = """
        <Configuration xmlns="http://test.example.com/Model/InventoryConfiguration">
            <Name>Catalog Alpha</Name>
            <Details>
                <Controls>
                    <Control>
                        <Field><Source>Product</Source><Attribute>SKU</Attribute></Field>
                        <DataType>Text</DataType>
                        <Required>False</Required>
                        <ReadOnly>False</ReadOnly>
                        <MaximumLength>20</MaximumLength>
                    </Control>
                    <Control>
                        <Field><Source>Product</Source><Attribute>Name</Attribute></Field>
                        <DataType>Text</DataType>
                        <Required>False</Required>
                        <ReadOnly>False</ReadOnly>
                        <MaximumLength>350</MaximumLength>
                    </Control>
                </Controls>
            </Details>
            <ItemSearching>
                <Sources>
                    <Source>Product</Source>
                    <Source>Warehouse</Source>
                </Sources>
                <Target>Product</Target>
                <Criteria>
                    <Criterion>
                        <Label>Brand</Label>
                        <Type>Text</Type>
                        <Field><Source>Product</Source><Attribute>Brand</Attribute></Field>
                    </Criterion>
                </Criteria>
                <Columns>
                    <Column>
                        <Type>Text</Type>
                        <Field><Source>Product</Source><Attribute>Model</Attribute></Field>
                    </Column>
                </Columns>
            </ItemSearching>
            <ShipmentSearching>
                <Sources>
                    <Source>Shipment</Source>
                </Sources>
                <Target>Shipment</Target>
                <ReadOnlyCriteria>
                    <Criterion>
                        <Type>Text</Type>
                        <Field><Source>Product</Source><Attribute>SKU</Attribute></Field>
                    </Criterion>
                </ReadOnlyCriteria>
                <Columns>
                    <Column>
                        <Type>Text</Type>
                        <Field><Source>Warehouse</Source><Attribute>BinNumber</Attribute></Field>
                    </Column>
                </Columns>
            </ShipmentSearching>
        </Configuration>
        """.data(using: .utf8)!

        do {
            let config = try decoder.decode(Configuration.self, from: data)
            XCTAssertEqual(config.Name, "Catalog Alpha")
            XCTAssertEqual(config.Details.Controls.count, 2)
            XCTAssertEqual(config.Details.Controls[0].Field.Source, "Product")
            XCTAssertEqual(config.Details.Controls[0].Field.Attribute, "SKU")
            XCTAssertEqual(config.Details.Controls[0].DataType, "Text")
            XCTAssertEqual(config.Details.Controls[0].MaximumLength, 20)
            XCTAssertNil(config.Details.Controls[0].Label)
            XCTAssertNil(config.Details.Controls[0].Choices)

            XCTAssertEqual(config.ItemSearching.Sources, ["Product", "Warehouse"])
            XCTAssertEqual(config.ItemSearching.Target, "Product")
            XCTAssertEqual(config.ItemSearching.Criteria.count, 1)
            XCTAssertEqual(config.ItemSearching.Criteria[0].Label, "Brand")

            XCTAssertEqual(config.ShipmentSearching.Sources, ["Shipment"])
            XCTAssertEqual(config.ShipmentSearching.Target, "Shipment")
            XCTAssertEqual(config.ShipmentSearching.ReadOnlyCriteria.count, 1)
        } catch {
            XCTFail("Decode failed: \(error)")
        }
    }

    // MARK: - Empty ReadOnlyCriteria

    func testDecodeConfigurationWithEmptyReadOnlyCriteria() {
        let decoder = XMLDecoder()
        let data = """
        <Configuration xmlns="http://test.example.com/Model/InventoryConfiguration">
            <Name>Catalog Beta</Name>
            <Details>
                <Controls>
                    <Control>
                        <Field><Source>Product</Source><Attribute>SKU</Attribute></Field>
                        <DataType>Text</DataType>
                        <Required>False</Required>
                        <ReadOnly>False</ReadOnly>
                        <MaximumLength>20</MaximumLength>
                    </Control>
                </Controls>
            </Details>
            <ItemSearching>
                <Sources><Source>Product</Source></Sources>
                <Target>Product</Target>
                <Criteria>
                    <Criterion>
                        <Label>Brand</Label>
                        <Type>Text</Type>
                        <Field><Source>Product</Source><Attribute>Brand</Attribute></Field>
                    </Criterion>
                </Criteria>
                <Columns>
                    <Column>
                        <Type>Text</Type>
                        <Field><Source>Product</Source><Attribute>Model</Attribute></Field>
                    </Column>
                </Columns>
            </ItemSearching>
            <ShipmentSearching>
                <Sources><Source>Warehouse</Source></Sources>
                <Target>Warehouse</Target>
                <ReadOnlyCriteria />
                <Columns>
                    <Column>
                        <Type>Date</Type>
                        <Field><Source>Warehouse</Source><Attribute>ReceivedDate</Attribute></Field>
                    </Column>
                </Columns>
            </ShipmentSearching>
        </Configuration>
        """.data(using: .utf8)!


        do {
            let config = try decoder.decode(Configuration.self, from: data)
            XCTAssertEqual(config.Name, "Catalog Beta")
            XCTAssertEqual(config.ShipmentSearching.ReadOnlyCriteria, [])
        } catch {
            XCTFail("Decode failed: \(error)")
        }
    }

    // MARK: - Empty Choices on Control

    func testDecodeControlWithEmptyChoices() {
        let decoder = XMLDecoder()
        let data = """
        <Configuration xmlns="http://test.example.com/Model/InventoryConfiguration">
            <Name>Choices Test</Name>
            <Details>
                <Controls>
                    <Control>
                        <Field><Source>Warehouse</Source><Attribute>Zone</Attribute></Field>
                        <DataType>Text</DataType>
                        <Required>False</Required>
                        <ReadOnly>False</ReadOnly>
                        <MaximumLength>100</MaximumLength>
                        <Choices />
                    </Control>
                </Controls>
            </Details>
            <ItemSearching>
                <Sources><Source>Product</Source></Sources>
                <Target>Product</Target>
                <Criteria>
                    <Criterion><Type>Text</Type><Field><Source>Product</Source><Attribute>SKU</Attribute></Field></Criterion>
                </Criteria>
                <Columns>
                    <Column><Type>Text</Type><Field><Source>Product</Source><Attribute>SKU</Attribute></Field></Column>
                </Columns>
            </ItemSearching>
            <ShipmentSearching>
                <Sources><Source>Shipment</Source></Sources>
                <Target>Shipment</Target>
                <ReadOnlyCriteria />
                <Columns>
                    <Column><Type>Text</Type><Field><Source>Shipment</Source><Attribute>TrackingNumber</Attribute></Field></Column>
                </Columns>
            </ShipmentSearching>
        </Configuration>
        """.data(using: .utf8)!

        do {
            let config = try decoder.decode(Configuration.self, from: data)
            XCTAssertEqual(config.Details.Controls.count, 1)
            // Empty <Choices /> should decode as nil
            XCTAssertNil(config.Details.Controls[0].Choices)
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
            XCTAssertEqual(first.Name, "Catalog Alpha")
            XCTAssertEqual(first.Details.Controls.count, 23)

            // Verify first control
            XCTAssertEqual(first.Details.Controls[0].Field.Source, "Product")
            XCTAssertEqual(first.Details.Controls[0].Field.Attribute, "SKU")
            XCTAssertEqual(first.Details.Controls[0].DataType, "Text")
            XCTAssertEqual(first.Details.Controls[0].MaximumLength, 20)

            // Verify ItemSearching
            XCTAssertEqual(first.ItemSearching.Sources, ["Product", "Warehouse"])
            XCTAssertEqual(first.ItemSearching.Target, "Product")
            XCTAssertEqual(first.ItemSearching.Criteria.count, 5)
            XCTAssertEqual(first.ItemSearching.Criteria[0].Label, "Brand")
            XCTAssertEqual(first.ItemSearching.Columns.count, 8)

            // Verify ShipmentSearching — has ReadOnlyCriteria
            XCTAssertEqual(first.ShipmentSearching.Sources, ["Shipment"])
            XCTAssertEqual(first.ShipmentSearching.Target, "Shipment")
            XCTAssertEqual(first.ShipmentSearching.ReadOnlyCriteria.count, 6)
            XCTAssertEqual(first.ShipmentSearching.Columns.count, 8)

            let second = feed.entry[1].content.configuration
            XCTAssertEqual(second.Name, "Catalog Beta")
            XCTAssertEqual(second.Details.Controls.count, 23)

            // Second entry has empty ReadOnlyCriteria
            XCTAssertEqual(second.ShipmentSearching.ReadOnlyCriteria, [])
            XCTAssertEqual(second.ShipmentSearching.Columns.count, 15)

            // Verify a criterion without Label
            let criterion = first.ItemSearching.Criteria[2]  // ManufactureDate — no Label
            XCTAssertNil(criterion.Label)
            XCTAssertEqual(criterion.Type, "Date")
            XCTAssertEqual(criterion.Field.Attribute, "ManufactureDate")

            // Verify a column with Label
            let labeledColumn = first.ItemSearching.Columns[6]  // Weight
            XCTAssertEqual(labeledColumn.Label, "Weight")

            // Verify last control is read-only
            let lastControl = first.Details.Controls[22]
            XCTAssertEqual(lastControl.ReadOnly, "True")
            XCTAssertEqual(lastControl.Field.Attribute, "Supplier")
        } catch {
            XCTFail("Decode failed: \(error)")
        }
    }

    // MARK: - Full XML Fixture

    // Synthetic Atom feed using a fictional inventory domain.
    // All URLs, identifiers, and field names are purely illustrative.
    static let fullAtomFeedXML = """
    <?xml version="1.0" encoding="utf-8"?>\
    <feed xmlns="http://www.w3.org/2005/Atom">\
    <id>http://feed.example.com/Tenant/00000/InventoryConfigurations</id>\
    <title>Inventory Configurations</title>\
    <updated>2025-01-01T00:00:00Z</updated>\
    <author><name>Admin</name></author>\
    <entry>\
    <id>http://feed.example.com/Tenant/00000/InventoryConfiguration/1001</id>\
    <title>Inventory Configuration</title>\
    <updated>2025-01-01T00:00:00Z</updated>\
    <author><name>Admin</name></author>\
    <link rel="alternate" href="https://api.example.com/Tenant/00000/InventoryConfiguration/1001" />\
    <content type="text/xml">\
    <Configuration xmlns="http://test.example.com/Model/InventoryConfiguration">\
    <Name>Catalog Alpha</Name>\
    <Details><Controls>\
    <Control><Field><Source>Product</Source><Attribute>SKU</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>20</MaximumLength></Control>\
    <Control><Field><Source>Product</Source><Attribute>Name</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>350</MaximumLength></Control>\
    <Control><Field><Source>Product</Source><Attribute>Category</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>1</MaximumLength></Control>\
    <Control><Field><Source>Product</Source><Attribute>ManufactureDate</Attribute></Field><DataType>Date</DataType><Required>False</Required><ReadOnly>False</ReadOnly></Control>\
    <Control><Field><Source>Warehouse</Source><Attribute>TrackingNumber</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>50</MaximumLength></Control>\
    <Control><Field><Source>Warehouse</Source><Attribute>BinNumber</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>50</MaximumLength></Control>\
    <Control><Field><Source>Warehouse</Source><Attribute>ReceivedDate</Attribute></Field><DataType>Date</DataType><Required>False</Required><ReadOnly>False</ReadOnly></Control>\
    <Control><Field><Source>Warehouse</Source><Attribute>ReceivedTime</Attribute></Field><DataType>Time</DataType><Required>False</Required><ReadOnly>False</ReadOnly></Control>\
    <Control><Field><Source>Catalog</Source><Attribute>ListedDate</Attribute></Field><DataType>Moment</DataType><Required>False</Required><ReadOnly>False</ReadOnly></Control>\
    <Control><Field><Source>Warehouse</Source><Attribute>StockedDate</Attribute></Field><DataType>Moment</DataType><Required>False</Required><ReadOnly>False</ReadOnly></Control>\
    <Control><Field><Source>Warehouse</Source><Attribute>ShippedDate</Attribute></Field><DataType>Moment</DataType><Required>False</Required><ReadOnly>False</ReadOnly></Control>\
    <Control><Field><Source>Catalog</Source><Attribute>Publisher</Attribute></Field><DataType>Uri</DataType><Required>False</Required><ReadOnly>False</ReadOnly></Control>\
    <Control><Field><Source>Catalog</Source><Attribute>ListingType</Attribute></Field><DataType>Uri</DataType><Required>False</Required><ReadOnly>False</ReadOnly></Control>\
    <Control><Field><Source>Catalog</Source><Attribute>Region</Attribute></Field><DataType>Uri</DataType><Required>False</Required><ReadOnly>False</ReadOnly></Control>\
    <Control><Field><Source>Catalog</Source><Attribute>Featured</Attribute></Field><DataType>Uri</DataType><Required>False</Required><ReadOnly>False</ReadOnly></Control>\
    <Control><Field><Source>Warehouse</Source><Attribute>CustomField1</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>100</MaximumLength><Choices /></Control>\
    <Control><Field><Source>Warehouse</Source><Attribute>CustomField2</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>100</MaximumLength><Choices /></Control>\
    <Control><Field><Source>Warehouse</Source><Attribute>CustomField3</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>100</MaximumLength><Choices /></Control>\
    <Control><Field><Source>Warehouse</Source><Attribute>CustomField4</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>100</MaximumLength><Choices /></Control>\
    <Control><Field><Source>Warehouse</Source><Attribute>CustomField5</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>100</MaximumLength><Choices /></Control>\
    <Control><Field><Source>Warehouse</Source><Attribute>Aisle</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>20</MaximumLength></Control>\
    <Control><Field><Source>Warehouse</Source><Attribute>Shelf</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>20</MaximumLength></Control>\
    <Control><Field><Source>Warehouse</Source><Attribute>Supplier</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>True</ReadOnly></Control>\
    </Controls></Details>\
    <ItemSearching>\
    <Sources><Source>Product</Source><Source>Warehouse</Source></Sources>\
    <Target>Product</Target>\
    <Criteria>\
    <Criterion><Label>Brand</Label><Type>Text</Type><Field><Source>Product</Source><Attribute>Brand</Attribute></Field></Criterion>\
    <Criterion><Label>Model</Label><Type>Text</Type><Field><Source>Product</Source><Attribute>Model</Attribute></Field></Criterion>\
    <Criterion><Type>Date</Type><Field><Source>Product</Source><Attribute>ManufactureDate</Attribute></Field></Criterion>\
    <Criterion><Type>Text</Type><Field><Source>Product</Source><Attribute>SKU</Attribute></Field></Criterion>\
    <Criterion><Label>Weight</Label><Type>Text</Type><Field><Source>Warehouse</Source><Attribute>GrossWeight</Attribute></Field></Criterion>\
    </Criteria>\
    <Columns>\
    <Column><Type>Text</Type><Field><Source>Product</Source><Attribute>Model</Attribute></Field></Column>\
    <Column><Type>Text</Type><Field><Source>Product</Source><Attribute>Brand</Attribute></Field></Column>\
    <Column><Type>Text</Type><Field><Source>Product</Source><Attribute>Category</Attribute></Field></Column>\
    <Column><Type>Date</Type><Field><Source>Product</Source><Attribute>ManufactureDate</Attribute></Field></Column>\
    <Column><Type>Date</Type><Field><Source>Product</Source><Attribute>ReceivedDate</Attribute></Field></Column>\
    <Column><Type>Text</Type><Field><Source>Product</Source><Attribute>SKU</Attribute></Field></Column>\
    <Column><Label>Weight</Label><Type>Text</Type><Field><Source>Warehouse</Source><Attribute>GrossWeight</Attribute></Field></Column>\
    <Column><Label>Region</Label><Type>Text</Type><Field><Source>Warehouse</Source><Attribute>RegionName</Attribute></Field></Column>\
    </Columns>\
    </ItemSearching>\
    <ShipmentSearching>\
    <Sources><Source>Shipment</Source></Sources>\
    <Target>Shipment</Target>\
    <ReadOnlyCriteria>\
    <Criterion><Type>Text</Type><Field><Source>Product</Source><Attribute>SKU</Attribute></Field></Criterion>\
    <Criterion><Type>Text</Type><Field><Source>Product</Source><Attribute>Name</Attribute></Field></Criterion>\
    <Criterion><Type>Date</Type><Field><Source>Product</Source><Attribute>ManufactureDate</Attribute></Field></Criterion>\
    <Criterion><Type>Text</Type><Field><Source>Product</Source><Attribute>Category</Attribute></Field></Criterion>\
    <Criterion><Type>Text</Type><Field><Source>Product</Source><Attribute>Model</Attribute></Field></Criterion>\
    <Criterion><Type>Text</Type><Field><Source>Product</Source><Attribute>Brand</Attribute></Field></Criterion>\
    </ReadOnlyCriteria>\
    <Columns>\
    <Column><Type>Text</Type><Field><Source>Warehouse</Source><Attribute>BinNumber</Attribute></Field></Column>\
    <Column><Type>Moment</Type><Field><Source>Warehouse</Source><Attribute>StockedDate</Attribute></Field></Column>\
    <Column><Type>Text</Type><Field><Source>Shipment</Source><Attribute>TrackingNumber</Attribute></Field></Column>\
    <Column><Type>Text</Type><Field><Source>Shipment</Source><Attribute>CarrierCode</Attribute></Field></Column>\
    <Column><Type>Text</Type><Field><Source>Shipment</Source><Attribute>Status</Attribute></Field></Column>\
    <Column><Type>Date</Type><Field><Source>Shipment</Source><Attribute>ShipDate</Attribute></Field></Column>\
    <Column><Type>Text</Type><Field><Source>Shipment</Source><Attribute>Description</Attribute></Field></Column>\
    <Column><Type>Text</Type><Field><Source>Shipment</Source><Attribute>Carrier</Attribute></Field></Column>\
    </Columns>\
    </ShipmentSearching>\
    </Configuration>\
    </content>\
    </entry>\
    <entry>\
    <id>http://feed.example.com/Tenant/00000/InventoryConfiguration/1002</id>\
    <title>Inventory Configuration</title>\
    <updated>2025-01-01T00:00:00Z</updated>\
    <author><name>Admin</name></author>\
    <link rel="alternate" href="https://api.example.com/Tenant/00000/InventoryConfiguration/1002" />\
    <content type="text/xml">\
    <Configuration xmlns="http://test.example.com/Model/InventoryConfiguration">\
    <Name>Catalog Beta</Name>\
    <Details><Controls>\
    <Control><Field><Source>Product</Source><Attribute>SKU</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>20</MaximumLength></Control>\
    <Control><Field><Source>Product</Source><Attribute>Name</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>350</MaximumLength></Control>\
    <Control><Field><Source>Product</Source><Attribute>Category</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>1</MaximumLength></Control>\
    <Control><Field><Source>Product</Source><Attribute>ManufactureDate</Attribute></Field><DataType>Date</DataType><Required>False</Required><ReadOnly>False</ReadOnly></Control>\
    <Control><Field><Source>Warehouse</Source><Attribute>ReceivedDate</Attribute></Field><DataType>Date</DataType><Required>False</Required><ReadOnly>False</ReadOnly></Control>\
    <Control><Field><Source>Warehouse</Source><Attribute>ReceivedTime</Attribute></Field><DataType>Time</DataType><Required>False</Required><ReadOnly>False</ReadOnly></Control>\
    <Control><Field><Source>Catalog</Source><Attribute>ListedDate</Attribute></Field><DataType>Moment</DataType><Required>False</Required><ReadOnly>False</ReadOnly></Control>\
    <Control><Field><Source>Warehouse</Source><Attribute>StockedDate</Attribute></Field><DataType>Moment</DataType><Required>False</Required><ReadOnly>False</ReadOnly></Control>\
    <Control><Field><Source>Warehouse</Source><Attribute>ShippedDate</Attribute></Field><DataType>Moment</DataType><Required>False</Required><ReadOnly>False</ReadOnly></Control>\
    <Control><Field><Source>Warehouse</Source><Attribute>TrackingNumber</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>50</MaximumLength></Control>\
    <Control><Field><Source>Catalog</Source><Attribute>Publisher</Attribute></Field><DataType>Uri</DataType><Required>False</Required><ReadOnly>False</ReadOnly></Control>\
    <Control><Field><Source>Catalog</Source><Attribute>ListingType</Attribute></Field><DataType>Uri</DataType><Required>False</Required><ReadOnly>False</ReadOnly></Control>\
    <Control><Field><Source>Catalog</Source><Attribute>Region</Attribute></Field><DataType>Uri</DataType><Required>False</Required><ReadOnly>False</ReadOnly></Control>\
    <Control><Field><Source>Catalog</Source><Attribute>Featured</Attribute></Field><DataType>Uri</DataType><Required>False</Required><ReadOnly>False</ReadOnly></Control>\
    <Control><Field><Source>Warehouse</Source><Attribute>CustomField1</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>100</MaximumLength><Choices /></Control>\
    <Control><Field><Source>Warehouse</Source><Attribute>CustomField2</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>100</MaximumLength><Choices /></Control>\
    <Control><Field><Source>Warehouse</Source><Attribute>CustomField3</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>100</MaximumLength><Choices /></Control>\
    <Control><Field><Source>Warehouse</Source><Attribute>CustomField4</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>100</MaximumLength><Choices /></Control>\
    <Control><Field><Source>Warehouse</Source><Attribute>CustomField5</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>100</MaximumLength><Choices /></Control>\
    <Control><Field><Source>Warehouse</Source><Attribute>Aisle</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>20</MaximumLength></Control>\
    <Control><Field><Source>Warehouse</Source><Attribute>BinNumber</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>50</MaximumLength></Control>\
    <Control><Field><Source>Warehouse</Source><Attribute>Shelf</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>False</ReadOnly><MaximumLength>20</MaximumLength></Control>\
    <Control><Field><Source>Warehouse</Source><Attribute>Supplier</Attribute></Field><DataType>Text</DataType><Required>False</Required><ReadOnly>True</ReadOnly></Control>\
    </Controls></Details>\
    <ItemSearching>\
    <Sources><Source>Product</Source><Source>Warehouse</Source></Sources>\
    <Target>Product</Target>\
    <Criteria>\
    <Criterion><Label>Brand</Label><Type>Text</Type><Field><Source>Product</Source><Attribute>Brand</Attribute></Field></Criterion>\
    <Criterion><Label>Model</Label><Type>Text</Type><Field><Source>Product</Source><Attribute>Model</Attribute></Field></Criterion>\
    <Criterion><Type>Date</Type><Field><Source>Product</Source><Attribute>ManufactureDate</Attribute></Field></Criterion>\
    <Criterion><Type>Text</Type><Field><Source>Product</Source><Attribute>SKU</Attribute></Field></Criterion>\
    <Criterion><Label>Weight</Label><Type>Text</Type><Field><Source>Warehouse</Source><Attribute>GrossWeight</Attribute></Field></Criterion>\
    </Criteria>\
    <Columns>\
    <Column><Type>Text</Type><Field><Source>Product</Source><Attribute>Model</Attribute></Field></Column>\
    <Column><Type>Text</Type><Field><Source>Product</Source><Attribute>Brand</Attribute></Field></Column>\
    <Column><Type>Text</Type><Field><Source>Product</Source><Attribute>Category</Attribute></Field></Column>\
    <Column><Type>Date</Type><Field><Source>Product</Source><Attribute>ManufactureDate</Attribute></Field></Column>\
    <Column><Type>Date</Type><Field><Source>Product</Source><Attribute>ReceivedDate</Attribute></Field></Column>\
    <Column><Type>Text</Type><Field><Source>Product</Source><Attribute>SKU</Attribute></Field></Column>\
    <Column><Label>Weight</Label><Type>Text</Type><Field><Source>Warehouse</Source><Attribute>GrossWeight</Attribute></Field></Column>\
    <Column><Label>Region</Label><Type>Text</Type><Field><Source>Warehouse</Source><Attribute>RegionName</Attribute></Field></Column>\
    </Columns>\
    </ItemSearching>\
    <ShipmentSearching>\
    <Sources><Source>Warehouse</Source></Sources>\
    <Target>Warehouse</Target>\
    <ReadOnlyCriteria />\
    <Columns>\
    <Column><Type>Date</Type><Field><Source>Warehouse</Source><Attribute>ReceivedDate</Attribute></Field></Column>\
    <Column><Type>Time</Type><Field><Source>Warehouse</Source><Attribute>ReceivedTime</Attribute></Field></Column>\
    <Column><Label>Description</Label><Type>Text</Type><Field><Source>Warehouse</Source><Attribute>Description</Attribute></Field></Column>\
    <Column><Type>Text</Type><Field><Source>Product</Source><Attribute>SKU</Attribute></Field></Column>\
    <Column><Type>Text</Type><Field><Source>Product</Source><Attribute>Name</Attribute></Field></Column>\
    <Column><Type>Text</Type><Field><Source>Product</Source><Attribute>Category</Attribute></Field></Column>\
    <Column><Type>Date</Type><Field><Source>Product</Source><Attribute>ManufactureDate</Attribute></Field></Column>\
    <Column><Label>Region ID</Label><Type>Text</Type><Field><Source>Warehouse</Source><Attribute>RegionId</Attribute></Field></Column>\
    <Column><Label>Region Name</Label><Type>Text</Type><Field><Source>Warehouse</Source><Attribute>RegionName</Attribute></Field></Column>\
    <Column><Type>Text</Type><Field><Source>Warehouse</Source><Attribute>TrackingNumber</Attribute></Field></Column>\
    <Column><Type>Text</Type><Field><Source>Warehouse</Source><Attribute>CustomField1</Attribute></Field></Column>\
    <Column><Type>Text</Type><Field><Source>Warehouse</Source><Attribute>CustomField2</Attribute></Field></Column>\
    <Column><Type>Text</Type><Field><Source>Warehouse</Source><Attribute>CustomField3</Attribute></Field></Column>\
    <Column><Type>Text</Type><Field><Source>Warehouse</Source><Attribute>CustomField4</Attribute></Field></Column>\
    <Column><Type>Text</Type><Field><Source>Warehouse</Source><Attribute>CustomField5</Attribute></Field></Column>\
    </Columns>\
    </ShipmentSearching>\
    </Configuration>\
    </content>\
    </entry>\
    </feed>
    """
}
