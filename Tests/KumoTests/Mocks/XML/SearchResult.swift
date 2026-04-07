// Models for decoding search query/result XML payloads.
// Used by KumoCoding XMLDecoder tests.
//
// Covers patterns:
// - Atom feed with multiple <entry> rows (unkeyed iteration)
// - Polymorphic <Data> elements containing one of <Uri>, <Moment>, or <Text>
// - Self-closing / empty elements (<Moment />, <Text />, <Text></Text>, <Uri />)
// - Nested wrapper arrays (Fields > Item, Parameters > Parameter)
// - Mixed sibling types in <entry> (id, title, updated, author, link, content)
import Foundation

// MARK: - Atom Feed Wrappers

/// Top-level Atom `<feed>` element containing search result `<entry>` rows.
/// Uses the same unkeyed-container pattern as HeaderConfigurationFeed to
/// iterate mixed children and collect entry elements.
struct SearchResultFeed: Decodable {
    let entries: [SearchResultEntry]

    init(from decoder: Decoder) throws {
        var results: [SearchResultEntry] = []
        var container = try decoder.unkeyedContainer()
        while !container.isAtEnd {
            if let entry = try? container.decode(SearchResultEntry.self) {
                results.append(entry)
            }
        }
        self.entries = results
    }
}

/// Single Atom `<entry>` whose `<content>` holds a `SearchResultRow`.
struct SearchResultEntry: Decodable {
    let content: SearchResultContent

    private enum CodingKeys: String, CodingKey {
        case content
    }
}

/// The `<content>` wrapper containing the nested `Row`.
struct SearchResultContent: Decodable {
    let row: SearchResultRow

    private enum CodingKeys: String, CodingKey {
        case row = "Row"
    }
}

// MARK: - Search Query (request payload)

/// A search query containing sources, parameters, and requested columns.
///
/// XML structure:
/// ```
/// <Query xmlns="...">
///   <Sources><Source>...</Source></Sources>
///   <Parameters>
///     <Parameter><Field>...</Field><Data>...</Data></Parameter>
///   </Parameters>
///   <Columns><Field>...</Field></Columns>
/// </Query>
/// ```
struct SearchQuery: Decodable, Equatable {
    let Sources: [String]
    let Parameters: [SearchParameter]
    let Columns: [FieldModel]

    private enum CodingKeys: String, CodingKey {
        case Sources
        case Parameters
        case Columns
    }
}

/// A single query parameter binding a field to a data value.
struct SearchParameter: Decodable, Equatable {
    let Field: FieldModel
    let Data: DataValue

    private enum CodingKeys: String, CodingKey {
        case Field
        case Data
    }
}

// MARK: - Search Result Row (response payload)

/// A single search result row containing an identifier, source, and
/// a dynamic list of field/value items.
///
/// XML structure:
/// ```
/// <Row xmlns="...">
///   <Id>...</Id>
///   <Source>...</Source>
///   <Fields>
///     <Item><Field>...</Field><Data>...</Data></Item>
///   </Fields>
/// </Row>
/// ```
struct SearchResultRow: Decodable, Equatable {
    let Id: String
    let Source: String
    let Fields: [SearchResultItem]

    private enum CodingKeys: String, CodingKey {
        case Id
        case Source
        case Fields
    }
}

/// A single field/value pair within a result row.
struct SearchResultItem: Decodable, Equatable {
    let Field: FieldModel
    let Data: DataValue

    private enum CodingKeys: String, CodingKey {
        case Field
        case Data
    }
}

// MARK: - Polymorphic Data Value

/// Represents a polymorphic data element that contains exactly one of:
/// - `<Uri>value</Uri>` — a resource identifier / link
/// - `<Moment>value</Moment>` — a timestamp string
/// - `<Text>value</Text>` — plain text
///
/// Any of these child elements may be self-closing or empty, indicating
/// an absent/null value (e.g. `<Moment />`, `<Text></Text>`, `<Uri />`).
struct DataValue: Decodable, Equatable {
    let Uri: String?
    let Moment: String?
    let Text: String?

    private enum CodingKeys: String, CodingKey {
        case Uri
        case Moment
        case Text
    }

    init(uri: String? = nil, moment: String? = nil, text: String? = nil) {
        self.Uri = uri
        self.Moment = moment
        self.Text = text
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Each sub-element may be absent, empty/self-closing, or have content.
        // decodeIfPresent returns nil when the key is absent.
        // When present but empty (<Uri />), the String decode returns "".
        if container.contains(.Uri) {
            let isNil = try container.decodeNil(forKey: .Uri)
            Uri = isNil ? nil : try container.decode(String.self, forKey: .Uri)
        } else {
            Uri = nil
        }

        if container.contains(.Moment) {
            let isNil = try container.decodeNil(forKey: .Moment)
            Moment = isNil ? nil : try container.decode(String.self, forKey: .Moment)
        } else {
            Moment = nil
        }

        if container.contains(.Text) {
            let isNil = try container.decodeNil(forKey: .Text)
            Text = isNil ? nil : try container.decode(String.self, forKey: .Text)
        } else {
            Text = nil
        }
    }
}
