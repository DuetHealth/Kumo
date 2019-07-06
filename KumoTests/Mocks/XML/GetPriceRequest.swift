import Foundation

struct GetPriceRequest: Encodable, Equatable {

    struct SKU: Encodable, Equatable {
        let value: String
    }

    struct Availability: Encodable, Equatable {
        let isAvailable: Bool
        let stock: UInt
    }

    struct Price: Encodable, Equatable {
        let amount: Double
        let units: String
        let discount: Double
    }

    let name: String
    let sku: SKU
    let availability: Availability
    let price: Price

}
