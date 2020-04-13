import Foundation

struct GetMessageListResponse: Decodable, Equatable {
    let messageList: [Message]
}
struct MessageList: Decodable, Equatable {}
struct Message: Decodable, Equatable {
    let date: String
}

struct ListContainer: Encodable, Equatable {
    let simpleList: [String]
}

struct ComplexListContainer: Encodable, Equatable {
    let complexList: [ComplexElement]
}

struct ComplexElement: Encodable, Equatable {
    let x: String
    let y: String
}
