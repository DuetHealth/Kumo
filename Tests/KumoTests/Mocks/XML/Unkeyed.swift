import Foundation

struct GetMessageListResponse: Decodable, Equatable {
    let messageList: [Message]
}
struct MessageList: Decodable, Equatable {}
struct Message: Decodable, Equatable {
    let date: String
}

struct ListContainer: Codable, Equatable {
    let simpleList: [String]
}

struct ComplexListContainer: Codable, Equatable {
    let complexList: [ComplexElement]
}

struct ComplexElement: Codable, Equatable {
    let x: String
    let y: String
}

struct NilableContainer: Decodable, Equatable {
    let name: String
    let nickname: String?
}

struct NilableEncodable: Encodable, Equatable {
    let name: String
    let nickname: String?

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        if let nickname = nickname {
            try container.encode(nickname, forKey: .nickname)
        } else {
            try container.encodeNil(forKey: .nickname)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case name, nickname
    }
}

struct SnakeCaseModel: Codable, Equatable {
    let firstName: String
    let lastName: String
}

struct DefaultKeyModel: Codable, Equatable {
    let title: String
    let count: Int
}
