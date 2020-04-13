import Foundation

struct Authenticate: Codable, Equatable {
    let username: String
    let password: String
    let deviceID: String
    let appID: String
}

struct AuthenticateResponse: Decodable, Equatable {
    let accountID: String
    let deviceTimeout: Int
    let displayName: String
    let legalName: String
    let name: String

    struct FeatureInformation: Decodable, Equatable {
        let allowRxRefill: Bool
        let disabledFeatures: [String]
        let enabledFeatures: [String]
    }

    let featureInformation: FeatureInformation
}
