import Foundation

struct SOAPBody<Contents> {

    enum SOAPKeys: String, CodingKey {
        case envelope = "Envelope"
        case body = "Body"
    }

    struct TypeKey: CodingKey {

        var intValue: Int?
        var stringValue: String

        init<T>(_ type: T) {
            stringValue = String(describing: type)
        }

        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        init?(intValue: Int) {
            return nil
        }

    }

    let contents: Contents

    init(contents: Contents) {
        self.contents = contents
    }

}

extension SOAPBody: Encodable where Contents: Encodable {

    func encode(to encoder: Encoder) throws {
        var root = encoder.container(keyedBy: SOAPKeys.self)
        var envelope = root.nestedContainer(keyedBy: SOAPKeys.self, forKey: .envelope)
        var body = envelope.nestedContainer(keyedBy: TypeKey.self, forKey: .body)
        try body.encode(contents, forKey: TypeKey(Contents.self))
    }

}

extension SOAPBody: Decodable where Contents: Decodable {

    init(from decoder: Decoder) throws {
        // We are ignoring the envelope here as it should be the root
        // of the document and we assume it exists.
        self.contents = try decoder.container(keyedBy: SOAPKeys.self)
            .nestedContainer(keyedBy: TypeKey.self, forKey: .body)
            .decode(Contents.self, forKey: TypeKey(Contents.self))
    }

}
