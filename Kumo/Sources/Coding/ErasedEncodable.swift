import Foundation

struct ErasedEncodable: Encodable {

    let base: Encodable
    private let implementation: (Encoder) throws -> ()

    init(_ base: Encodable) {
        self.base = base
        self.implementation = base.encode(to:)
    }

    func encode(to encoder: Encoder) throws {
        try implementation(encoder)
    }

}
