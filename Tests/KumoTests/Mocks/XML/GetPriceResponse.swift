import Foundation

struct GetPriceResponse: Codable, Equatable {
    struct Price: Codable, Equatable {
        let amount: Double
        let units: String
    }
    let price: Price
    let discount: Double
}
