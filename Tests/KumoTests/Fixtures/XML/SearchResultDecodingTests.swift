import Foundation
import XCTest
@testable import Kumo
@testable import KumoCoding

// All XML fixtures in this file are synthetic test data.
// The domain (library / book catalog) is fictional and used solely to
// exercise KumoCoding's XMLDecoder against query/result XML patterns
// including polymorphic data types, self-closing elements, and Atom feeds.

class SearchResultDecodingTests: XCTestCase {

    // MARK: - Search Query Decoding

    /// Decodes a standalone <Query> element with Sources, Parameters, and Columns.
    func testDecodeSearchQuery() {
        let decoder = XMLDecoder()
        let data = """
        <Query xmlns="http://test.example.com/Model/Search">
            <Sources>
                <Source>Book</Source>
            </Sources>
            <Parameters>
                <Parameter>
                    <Field>
                        <Source>Book</Source>
                        <Attribute>Author</Attribute>
                    </Field>
                    <Data>
                        <Uri>http://example.com/Tenant/100/Author/42</Uri>
                    </Data>
                </Parameter>
            </Parameters>
            <Columns>
                <Field>
                    <Source>Book</Source>
                    <Attribute>URI</Attribute>
                </Field>
                <Field>
                    <Source>Book</Source>
                    <Attribute>PublishedDate</Attribute>
                </Field>
                <Field>
                    <Source>Reader</Source>
                    <Attribute>Id</Attribute>
                </Field>
                <Field>
                    <Source>Reader</Source>
                    <Attribute>FullName</Attribute>
                </Field>
            </Columns>
        </Query>
        """.data(using: .utf8)!

        do {
            let query = try decoder.decode(SearchQuery.self, from: data)
            XCTAssertEqual(query.Sources, ["Book"])
            XCTAssertEqual(query.Parameters.count, 1)
            XCTAssertEqual(query.Parameters[0].Field.Source, "Book")
            XCTAssertEqual(query.Parameters[0].Field.Attribute, "Author")
            XCTAssertEqual(query.Parameters[0].Data.Uri, "http://example.com/Tenant/100/Author/42")
            XCTAssertNil(query.Parameters[0].Data.Moment)
            XCTAssertNil(query.Parameters[0].Data.Text)
            XCTAssertEqual(query.Columns.count, 4)
            XCTAssertEqual(query.Columns[0].Attribute, "URI")
            XCTAssertEqual(query.Columns[3].Source, "Reader")
        } catch {
            XCTFail("Decode failed: \(error)")
        }
    }

    // MARK: - Single Row with Polymorphic Data

    /// Decodes a single <Row> containing Uri, Moment, and Text data types.
    func testDecodeSingleRowWithPolymorphicData() {
        let decoder = XMLDecoder()
        let data = """
        <Row xmlns="http://test.example.com/Model/Search">
            <Id>http://example.com/Tenant/100/Book/5001</Id>
            <Source>Book</Source>
            <Fields>
                <Item>
                    <Field><Source>Book</Source><Attribute>URI</Attribute></Field>
                    <Data><Uri>http://example.com/Tenant/100/Book/5001</Uri></Data>
                </Item>
                <Item>
                    <Field><Source>Book</Source><Attribute>PublishedDate</Attribute></Field>
                    <Data><Moment>2025-03-15T10:30:00-05:00</Moment></Data>
                </Item>
                <Item>
                    <Field><Source>Reader</Source><Attribute>Id</Attribute></Field>
                    <Data><Text>R-414</Text></Data>
                </Item>
                <Item>
                    <Field><Source>Reader</Source><Attribute>FullName</Attribute></Field>
                    <Data><Text>Jane Doe</Text></Data>
                </Item>
            </Fields>
        </Row>
        """.data(using: .utf8)!

        do {
            let row = try decoder.decode(SearchResultRow.self, from: data)
            XCTAssertEqual(row.Id, "http://example.com/Tenant/100/Book/5001")
            XCTAssertEqual(row.Source, "Book")
            XCTAssertEqual(row.Fields.count, 4)

            // Item 0: Uri data
            XCTAssertEqual(row.Fields[0].Field.Source, "Book")
            XCTAssertEqual(row.Fields[0].Field.Attribute, "URI")
            XCTAssertEqual(row.Fields[0].Data.Uri, "http://example.com/Tenant/100/Book/5001")
            XCTAssertNil(row.Fields[0].Data.Moment)
            XCTAssertNil(row.Fields[0].Data.Text)

            // Item 1: Moment data
            XCTAssertNil(row.Fields[1].Data.Uri)
            XCTAssertEqual(row.Fields[1].Data.Moment, "2025-03-15T10:30:00-05:00")
            XCTAssertNil(row.Fields[1].Data.Text)

            // Item 2: Text data
            XCTAssertNil(row.Fields[2].Data.Uri)
            XCTAssertNil(row.Fields[2].Data.Moment)
            XCTAssertEqual(row.Fields[2].Data.Text, "R-414")

            // Item 3: Text data
            XCTAssertEqual(row.Fields[3].Data.Text, "Jane Doe")
        } catch {
            XCTFail("Decode failed: \(error)")
        }
    }

    // MARK: - Self-Closing / Empty Data Elements

    /// Tests that self-closing elements like <Moment />, <Text />,
    /// and empty elements like <Text></Text> decode as nil.
    func testDecodeSelfClosingDataElements() {
        let decoder = XMLDecoder()
        let data = """
        <Row xmlns="http://test.example.com/Model/Search">
            <Id>http://example.com/Tenant/100/Book/5002</Id>
            <Source>Book</Source>
            <Fields>
                <Item>
                    <Field><Source>Book</Source><Attribute>CheckoutDate</Attribute></Field>
                    <Data><Moment /></Data>
                </Item>
                <Item>
                    <Field><Source>Reader</Source><Attribute>Id</Attribute></Field>
                    <Data><Text></Text></Data>
                </Item>
                <Item>
                    <Field><Source>Reader</Source><Attribute>FullName</Attribute></Field>
                    <Data><Text /></Data>
                </Item>
                <Item>
                    <Field><Source>Shelf</Source><Attribute>URI</Attribute></Field>
                    <Data><Uri /></Data>
                </Item>
            </Fields>
        </Row>
        """.data(using: .utf8)!

        do {
            let row = try decoder.decode(SearchResultRow.self, from: data)
            XCTAssertEqual(row.Fields.count, 4)

            // <Moment /> — self-closing, should be nil
            XCTAssertNil(row.Fields[0].Data.Moment)
            XCTAssertNil(row.Fields[0].Data.Uri)
            XCTAssertNil(row.Fields[0].Data.Text)

            // <Text></Text> — empty content, should be nil
            XCTAssertNil(row.Fields[1].Data.Text)

            // <Text /> — self-closing, should be nil
            XCTAssertNil(row.Fields[2].Data.Text)

            // <Uri /> — self-closing, should be nil
            XCTAssertNil(row.Fields[3].Data.Uri)
        } catch {
            XCTFail("Decode failed: \(error)")
        }
    }

    // MARK: - Row with Mixed Populated and Empty Fields

    /// A row where some fields have values and others are empty/self-closing,
    /// mirroring real-world patterns where optional data is sparse.
    func testDecodeRowWithMixedPopulatedAndEmptyFields() {
        let decoder = XMLDecoder()
        let data = """
        <Row xmlns="http://test.example.com/Model/Search">
            <Id>http://example.com/Tenant/100/Book/5003</Id>
            <Source>Book</Source>
            <Fields>
                <Item>
                    <Field><Source>Book</Source><Attribute>URI</Attribute></Field>
                    <Data><Uri>http://example.com/Tenant/100/Book/5003</Uri></Data>
                </Item>
                <Item>
                    <Field><Source>Book</Source><Attribute>PublishedDate</Attribute></Field>
                    <Data><Moment>2025-06-01T14:00:00-05:00</Moment></Data>
                </Item>
                <Item>
                    <Field><Source>Book</Source><Attribute>CheckoutDate</Attribute></Field>
                    <Data><Moment /></Data>
                </Item>
                <Item>
                    <Field><Source>Reader</Source><Attribute>Id</Attribute></Field>
                    <Data><Text>R-123</Text></Data>
                </Item>
                <Item>
                    <Field><Source>Reader</Source><Attribute>FullName</Attribute></Field>
                    <Data><Text /></Data>
                </Item>
                <Item>
                    <Field><Source>Genre</Source><Attribute>URI</Attribute></Field>
                    <Data><Uri>http://example.com/Tenant/100/Genre/7001</Uri></Data>
                </Item>
                <Item>
                    <Field><Source>Shelf</Source><Attribute>URI</Attribute></Field>
                    <Data><Uri /></Data>
                </Item>
            </Fields>
        </Row>
        """.data(using: .utf8)!

        do {
            let row = try decoder.decode(SearchResultRow.self, from: data)
            XCTAssertEqual(row.Fields.count, 7)

            // Populated URI
            XCTAssertEqual(row.Fields[0].Data.Uri, "http://example.com/Tenant/100/Book/5003")
            // Populated Moment
            XCTAssertEqual(row.Fields[1].Data.Moment, "2025-06-01T14:00:00-05:00")
            // Empty Moment
            XCTAssertNil(row.Fields[2].Data.Moment)
            // Populated Text
            XCTAssertEqual(row.Fields[3].Data.Text, "R-123")
            // Empty Text
            XCTAssertNil(row.Fields[4].Data.Text)
            // Populated URI
            XCTAssertEqual(row.Fields[5].Data.Uri, "http://example.com/Tenant/100/Genre/7001")
            // Empty URI
            XCTAssertNil(row.Fields[6].Data.Uri)
        } catch {
            XCTFail("Decode failed: \(error)")
        }
    }

    // MARK: - Multiple Entries in Atom Feed

    /// Decodes a full Atom feed with 3 entries representing search results.
    /// Entry 1: fully populated (all data present, 9 fields including links)
    /// Entry 2: sparse data (empty Text/Moment, only 7 fields, no link fields)
    /// Entry 3: all fields populated with different data values
    func testDecodeSearchResultFeedWithMultipleEntries() {
        let decoder = XMLDecoder()
        let data = Self.searchResultFeedXML.data(using: .utf8)!

        do {
            let feed = try decoder.decode(SearchResultFeed.self, from: data)
            XCTAssertEqual(feed.entries.count, 3)

            // --- Entry 1: Fully populated ---
            let row1 = feed.entries[0].content.row
            XCTAssertEqual(row1.Id, "http://example.com/Tenant/100/Book/5001")
            XCTAssertEqual(row1.Source, "Book")
            XCTAssertEqual(row1.Fields.count, 9)

            // URI field
            XCTAssertEqual(row1.Fields[0].Field.Attribute, "URI")
            XCTAssertEqual(row1.Fields[0].Data.Uri, "http://example.com/Tenant/100/Book/5001")

            // Moment field (PublishedDate)
            XCTAssertEqual(row1.Fields[1].Field.Attribute, "PublishedDate")
            XCTAssertEqual(row1.Fields[1].Data.Moment, "2025-04-06T15:04:56-05:00")

            // Moment field (CheckoutDate) — self-closing <Moment />
            XCTAssertEqual(row1.Fields[2].Field.Attribute, "CheckoutDate")
            XCTAssertNil(row1.Fields[2].Data.Moment)

            // Text field (Reader Id)
            XCTAssertEqual(row1.Fields[3].Field.Attribute, "Id")
            XCTAssertEqual(row1.Fields[3].Data.Text, "R-414")

            // Text field (Reader FullName)
            XCTAssertEqual(row1.Fields[4].Field.Attribute, "FullName")
            XCTAssertEqual(row1.Fields[4].Data.Text, "Alice Wonderland")

            // Uri field (Genre)
            XCTAssertEqual(row1.Fields[5].Field.Attribute, "URI")
            XCTAssertEqual(row1.Fields[5].Data.Uri, "http://example.com/Tenant/100/Genre/7001")

            // Uri field (Shelf) — self-closing <Uri />
            XCTAssertEqual(row1.Fields[6].Field.Attribute, "URI")
            XCTAssertNil(row1.Fields[6].Data.Uri)

            // Link fields (ContentLink, DocumentLink)
            XCTAssertEqual(row1.Fields[7].Field.Attribute, "ContentLink")
            XCTAssertEqual(row1.Fields[7].Data.Uri,
                           "https://api.example.com/Tenant/100/Book/5001/Content/HTML")
            XCTAssertEqual(row1.Fields[8].Field.Attribute, "CoverLink")
            XCTAssertEqual(row1.Fields[8].Data.Uri,
                           "https://api.example.com/Tenant/100/Book/5001/Cover/JPG")

            // --- Entry 2: Sparse — empty Text and Moment fields, no links ---
            let row2 = feed.entries[1].content.row
            XCTAssertEqual(row2.Id, "http://example.com/Tenant/100/Book/5002")
            XCTAssertEqual(row2.Fields.count, 7)

            // Reader Id — empty <Text></Text>
            XCTAssertEqual(row2.Fields[3].Field.Source, "Reader")
            XCTAssertEqual(row2.Fields[3].Field.Attribute, "Id")
            XCTAssertNil(row2.Fields[3].Data.Text)

            // Reader FullName — self-closing <Text />
            XCTAssertEqual(row2.Fields[4].Field.Attribute, "FullName")
            XCTAssertNil(row2.Fields[4].Data.Text)

            // Shelf URI — self-closing <Uri />
            XCTAssertEqual(row2.Fields[6].Field.Attribute, "URI")
            XCTAssertNil(row2.Fields[6].Data.Uri)

            // --- Entry 3: All populated, different genre URI ---
            let row3 = feed.entries[2].content.row
            XCTAssertEqual(row3.Id, "http://example.com/Tenant/100/Book/5003")
            XCTAssertEqual(row3.Fields.count, 9)

            // Reader populated
            XCTAssertEqual(row3.Fields[3].Data.Text, "R-789")
            XCTAssertEqual(row3.Fields[4].Data.Text, "Bob Smith")

            // Different genre
            XCTAssertEqual(row3.Fields[5].Data.Uri, "http://example.com/Tenant/100/Genre/7002")
        } catch {
            XCTFail("Decode failed: \(error)")
        }
    }

    // MARK: - Query with Multiple Parameters

    /// Decodes a query that has multiple parameter bindings, testing that
    /// wrapper arrays with more than one child decode correctly.
    func testDecodeQueryWithMultipleParameters() {
        let decoder = XMLDecoder()
        let data = """
        <Query xmlns="http://test.example.com/Model/Search">
            <Sources>
                <Source>Book</Source>
                <Source>Reader</Source>
            </Sources>
            <Parameters>
                <Parameter>
                    <Field><Source>Book</Source><Attribute>Author</Attribute></Field>
                    <Data><Uri>http://example.com/Tenant/100/Author/42</Uri></Data>
                </Parameter>
                <Parameter>
                    <Field><Source>Book</Source><Attribute>Genre</Attribute></Field>
                    <Data><Text>Fiction</Text></Data>
                </Parameter>
                <Parameter>
                    <Field><Source>Book</Source><Attribute>PublishedAfter</Attribute></Field>
                    <Data><Moment>2024-01-01T00:00:00Z</Moment></Data>
                </Parameter>
            </Parameters>
            <Columns>
                <Field><Source>Book</Source><Attribute>Title</Attribute></Field>
                <Field><Source>Book</Source><Attribute>ISBN</Attribute></Field>
            </Columns>
        </Query>
        """.data(using: .utf8)!

        do {
            let query = try decoder.decode(SearchQuery.self, from: data)
            XCTAssertEqual(query.Sources, ["Book", "Reader"])
            XCTAssertEqual(query.Parameters.count, 3)

            // Parameter 1: Uri
            XCTAssertEqual(query.Parameters[0].Data.Uri, "http://example.com/Tenant/100/Author/42")
            XCTAssertNil(query.Parameters[0].Data.Text)
            XCTAssertNil(query.Parameters[0].Data.Moment)

            // Parameter 2: Text
            XCTAssertNil(query.Parameters[1].Data.Uri)
            XCTAssertEqual(query.Parameters[1].Data.Text, "Fiction")
            XCTAssertNil(query.Parameters[1].Data.Moment)

            // Parameter 3: Moment
            XCTAssertNil(query.Parameters[2].Data.Uri)
            XCTAssertNil(query.Parameters[2].Data.Text)
            XCTAssertEqual(query.Parameters[2].Data.Moment, "2024-01-01T00:00:00Z")

            XCTAssertEqual(query.Columns.count, 2)
            XCTAssertEqual(query.Columns[0].Attribute, "Title")
            XCTAssertEqual(query.Columns[1].Attribute, "ISBN")
        } catch {
            XCTFail("Decode failed: \(error)")
        }
    }

    // MARK: - Row with Minimum Fields

    /// Decodes a row with only the bare minimum fields (no link fields),
    /// ensuring the decoder handles varying field counts gracefully.
    func testDecodeRowWithMinimumFields() {
        let decoder = XMLDecoder()
        let data = """
        <Row xmlns="http://test.example.com/Model/Search">
            <Id>http://example.com/Tenant/100/Book/9999</Id>
            <Source>Book</Source>
            <Fields>
                <Item>
                    <Field><Source>Book</Source><Attribute>URI</Attribute></Field>
                    <Data><Uri>http://example.com/Tenant/100/Book/9999</Uri></Data>
                </Item>
            </Fields>
        </Row>
        """.data(using: .utf8)!

        do {
            let row = try decoder.decode(SearchResultRow.self, from: data)
            XCTAssertEqual(row.Id, "http://example.com/Tenant/100/Book/9999")
            XCTAssertEqual(row.Source, "Book")
            XCTAssertEqual(row.Fields.count, 1)
            XCTAssertEqual(row.Fields[0].Data.Uri, "http://example.com/Tenant/100/Book/9999")
        } catch {
            XCTFail("Decode failed: \(error)")
        }
    }

    // MARK: - Full Atom Feed XML Fixture

    // Synthetic Atom feed using a fictional library/book catalog domain.
    // Three entries with varying field counts and data completeness:
    //   Entry 1 (Book/5001): 9 fields, fully populated (Uri, Moment, Text, links)
    //   Entry 2 (Book/5002): 7 fields, sparse (empty Text, self-closing Moment/Uri, no links)
    //   Entry 3 (Book/5003): 9 fields, all populated with different values
    static let searchResultFeedXML = """
    <?xml version="1.0" encoding="utf-8"?>\
    <feed xmlns="http://www.w3.org/2005/Atom">\
    <id>http://example.com/Tenant/100/BookSearch</id>\
    <title>Book Search Results</title>\
    <updated>2025-04-07T12:00:00Z</updated>\
    <author><name>System</name></author>\
    <entry>\
    <id>http://example.com/Tenant/100/Book/5001</id>\
    <title>Row</title>\
    <updated>2025-04-07T12:00:00Z</updated>\
    <author><name>System</name></author>\
    <link rel="alternate" href="https://api.example.com/Tenant/100/Book/5001" />\
    <content type="text/xml">\
    <Row xmlns="http://test.example.com/Model/Search">\
    <Id>http://example.com/Tenant/100/Book/5001</Id>\
    <Source>Book</Source>\
    <Fields>\
    <Item><Field><Source>Book</Source><Attribute>URI</Attribute></Field><Data><Uri>http://example.com/Tenant/100/Book/5001</Uri></Data></Item>\
    <Item><Field><Source>Book</Source><Attribute>PublishedDate</Attribute></Field><Data><Moment>2025-04-06T15:04:56-05:00</Moment></Data></Item>\
    <Item><Field><Source>Book</Source><Attribute>CheckoutDate</Attribute></Field><Data><Moment /></Data></Item>\
    <Item><Field><Source>Reader</Source><Attribute>Id</Attribute></Field><Data><Text>R-414</Text></Data></Item>\
    <Item><Field><Source>Reader</Source><Attribute>FullName</Attribute></Field><Data><Text>Alice Wonderland</Text></Data></Item>\
    <Item><Field><Source>Genre</Source><Attribute>URI</Attribute></Field><Data><Uri>http://example.com/Tenant/100/Genre/7001</Uri></Data></Item>\
    <Item><Field><Source>Shelf</Source><Attribute>URI</Attribute></Field><Data><Uri /></Data></Item>\
    <Item><Field><Source>Book</Source><Attribute>ContentLink</Attribute></Field><Data><Uri>https://api.example.com/Tenant/100/Book/5001/Content/HTML</Uri></Data></Item>\
    <Item><Field><Source>Book</Source><Attribute>CoverLink</Attribute></Field><Data><Uri>https://api.example.com/Tenant/100/Book/5001/Cover/JPG</Uri></Data></Item>\
    </Fields>\
    </Row>\
    </content>\
    </entry>\
    <entry>\
    <id>http://example.com/Tenant/100/Book/5002</id>\
    <title>Row</title>\
    <updated>2025-04-07T12:00:00Z</updated>\
    <author><name>System</name></author>\
    <link rel="alternate" href="https://api.example.com/Tenant/100/Book/5002" />\
    <content type="text/xml">\
    <Row xmlns="http://test.example.com/Model/Search">\
    <Id>http://example.com/Tenant/100/Book/5002</Id>\
    <Source>Book</Source>\
    <Fields>\
    <Item><Field><Source>Book</Source><Attribute>URI</Attribute></Field><Data><Uri>http://example.com/Tenant/100/Book/5002</Uri></Data></Item>\
    <Item><Field><Source>Book</Source><Attribute>PublishedDate</Attribute></Field><Data><Moment>2025-04-06T15:03:52-05:00</Moment></Data></Item>\
    <Item><Field><Source>Book</Source><Attribute>CheckoutDate</Attribute></Field><Data><Moment /></Data></Item>\
    <Item><Field><Source>Reader</Source><Attribute>Id</Attribute></Field><Data><Text></Text></Data></Item>\
    <Item><Field><Source>Reader</Source><Attribute>FullName</Attribute></Field><Data><Text /></Data></Item>\
    <Item><Field><Source>Genre</Source><Attribute>URI</Attribute></Field><Data><Uri>http://example.com/Tenant/100/Genre/7001</Uri></Data></Item>\
    <Item><Field><Source>Shelf</Source><Attribute>URI</Attribute></Field><Data><Uri /></Data></Item>\
    </Fields>\
    </Row>\
    </content>\
    </entry>\
    <entry>\
    <id>http://example.com/Tenant/100/Book/5003</id>\
    <title>Row</title>\
    <updated>2025-04-07T12:00:00Z</updated>\
    <author><name>System</name></author>\
    <link rel="alternate" href="https://api.example.com/Tenant/100/Book/5003" />\
    <content type="text/xml">\
    <Row xmlns="http://test.example.com/Model/Search">\
    <Id>http://example.com/Tenant/100/Book/5003</Id>\
    <Source>Book</Source>\
    <Fields>\
    <Item><Field><Source>Book</Source><Attribute>URI</Attribute></Field><Data><Uri>http://example.com/Tenant/100/Book/5003</Uri></Data></Item>\
    <Item><Field><Source>Book</Source><Attribute>PublishedDate</Attribute></Field><Data><Moment>2025-03-15T10:30:00-05:00</Moment></Data></Item>\
    <Item><Field><Source>Book</Source><Attribute>CheckoutDate</Attribute></Field><Data><Moment /></Data></Item>\
    <Item><Field><Source>Reader</Source><Attribute>Id</Attribute></Field><Data><Text>R-789</Text></Data></Item>\
    <Item><Field><Source>Reader</Source><Attribute>FullName</Attribute></Field><Data><Text>Bob Smith</Text></Data></Item>\
    <Item><Field><Source>Genre</Source><Attribute>URI</Attribute></Field><Data><Uri>http://example.com/Tenant/100/Genre/7002</Uri></Data></Item>\
    <Item><Field><Source>Shelf</Source><Attribute>URI</Attribute></Field><Data><Uri /></Data></Item>\
    <Item><Field><Source>Book</Source><Attribute>ContentLink</Attribute></Field><Data><Uri>https://api.example.com/Tenant/100/Book/5003/Content/HTML</Uri></Data></Item>\
    <Item><Field><Source>Book</Source><Attribute>CoverLink</Attribute></Field><Data><Uri>https://api.example.com/Tenant/100/Book/5003/Cover/JPG</Uri></Data></Item>\
    </Fields>\
    </Row>\
    </content>\
    </entry>\
    </feed>
    """
}
