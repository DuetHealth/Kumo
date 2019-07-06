import Foundation

struct GetPriceResponse: Decodable, Equatable {
    struct Price: Decodable, Equatable {
        let amount: Double
        let units: String
    }
    let price: Price
    let discount: Double
}
