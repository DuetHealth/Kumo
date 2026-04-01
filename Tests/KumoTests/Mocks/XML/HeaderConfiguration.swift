// HeaderConfiguration models for decoding eSOne header_configurations.xml
// Adjusted from genspec output for KumoCoding XMLDecoder compatibility.
import Foundation

// MARK: - Atom Feed Wrappers

/// Top-level Atom `<feed>` element containing `<entry>` elements.
/// Uses a custom decoder because the Atom feed has mixed children
/// (id, title, updated, author, entry, …) and the KumoCoding XMLDecoder
/// only supports keyed-find-first, so we iterate with an unkeyed container
/// and collect successful entry decodes.
struct HeaderConfigurationFeed: Decodable {
    let entry: [HeaderConfigurationEntry]

    init(from decoder: Decoder) throws {
        var entries: [HeaderConfigurationEntry] = []
        var container = try decoder.unkeyedContainer()
        while !container.isAtEnd {
            if let entry = try? container.decode(HeaderConfigurationEntry.self) {
                entries.append(entry)
            }
        }
        self.entry = entries
    }
}

/// Single Atom `<entry>` whose `<content>` holds a `Configuration`.
struct HeaderConfigurationEntry: Decodable {
    let content: HeaderConfigurationContent

    private enum CodingKeys: String, CodingKey {
        case content = "content"
    }
}

/// The `<content>` wrapper that contains the nested `Configuration`.
struct HeaderConfigurationContent: Decodable {
    let configuration: Configuration

    private enum CodingKeys: String, CodingKey {
        case configuration = "Configuration"
    }
}

// MARK: - Domain Models

struct Configuration: Codable, Equatable {
    var Name: String
    var Demographics: Demographics
    var PatientSearching: PatientSearching
    var ArtifactSearching: ArtifactSearching

    private enum CodingKeys: String, CodingKey {
        case Name = "Name"
        case Demographics = "Demographics"
        case PatientSearching = "PatientSearching"
        case ArtifactSearching = "ArtifactSearching"
    }
}

struct Demographics: Codable, Equatable {
    var Controls: [Control]

    private enum CodingKeys: String, CodingKey {
        case Controls = "Controls"
    }
}

struct Control: Codable, Equatable {
    var Label: String?           // optional — not present in XML
    var Field: FieldModel
    var DataType: String
    var Required: String
    var ReadOnly: String
    var MaximumLength: Int?
    var Choices: [String]?       // optional — may be absent or empty self-closing tag

    private enum CodingKeys: String, CodingKey {
        case Label = "Label"
        case Field = "Field"
        case DataType = "DataType"
        case Required = "Required"
        case ReadOnly = "ReadOnly"
        case MaximumLength = "MaximumLength"
        case Choices = "Choices"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        Label = try container.decodeIfPresent(String.self, forKey: .Label)
        Field = try container.decode(FieldModel.self, forKey: .Field)
        DataType = try container.decode(String.self, forKey: .DataType)
        Required = try container.decode(String.self, forKey: .Required)
        ReadOnly = try container.decode(String.self, forKey: .ReadOnly)
        MaximumLength = try container.decodeIfPresent(Int.self, forKey: .MaximumLength)

        // Choices can be absent, empty (<Choices/>), or contain children.
        if container.contains(.Choices) {
            let isNil = try container.decodeNil(forKey: .Choices)
            if isNil {
                Choices = nil
            } else {
                Choices = try container.decode([String].self, forKey: .Choices)
            }
        } else {
            Choices = nil
        }
    }
}

struct FieldModel: Codable, Equatable {
    var Source: String
    var Attribute: String

    private enum CodingKeys: String, CodingKey {
        case Source = "Source"
        case Attribute = "Attribute"
    }
}

struct PatientSearching: Codable, Equatable {
    var Sources: [String]
    var Target: String
    var Criteria: [Criterion]
    var Columns: [Column]

    private enum CodingKeys: String, CodingKey {
        case Sources = "Sources"
        case Target = "Target"
        case Criteria = "Criteria"
        case Columns = "Columns"
    }
}

struct ArtifactSearching: Codable, Equatable {
    var Sources: [String]
    var Target: String
    var ReadOnlyCriteria: [Criterion]
    var Columns: [Column]

    private enum CodingKeys: String, CodingKey {
        case Sources = "Sources"
        case Target = "Target"
        case ReadOnlyCriteria = "ReadOnlyCriteria"
        case Columns = "Columns"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        Sources = try container.decode([String].self, forKey: .Sources)
        Target = try container.decode(String.self, forKey: .Target)

        // ReadOnlyCriteria can be an empty self-closing tag (<ReadOnlyCriteria />)
        let isNil = try container.decodeNil(forKey: .ReadOnlyCriteria)
        if isNil {
            ReadOnlyCriteria = []
        } else {
            ReadOnlyCriteria = try container.decode([Criterion].self, forKey: .ReadOnlyCriteria)
        }

        Columns = try container.decode([Column].self, forKey: .Columns)
    }
}

struct Criterion: Codable, Equatable {
    var Label: String?           // optional — not always present
    var `Type`: String
    var Field: FieldModel

    private enum CodingKeys: String, CodingKey {
        case Label = "Label"
        case `Type` = "Type"
        case Field = "Field"
    }
}

struct Column: Codable, Equatable {
    var Label: String?           // optional — not always present
    var `Type`: String
    var Field: FieldModel

    private enum CodingKeys: String, CodingKey {
        case Label = "Label"
        case `Type` = "Type"
        case Field = "Field"
    }
}
