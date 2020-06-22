import Foundation

public extension HTTP {

    struct Header: Hashable {

        public static let accept = HTTP.Header(rawValue: "Accept")
        public static let acceptLanguage = HTTP.Header(rawValue: "Accept-Language")
        public static let authorization = HTTP.Header(rawValue: "Authorization")
        public static let contentType = HTTP.Header(rawValue: "Content-Type")
        public static let contentLength = HTTP.Header(rawValue: "Content-Length")
        public static let userAgent = HTTP.Header(rawValue: "User-Agent")

        public static func custom(_ value: String) -> HTTP.Header {
            return HTTP.Header(rawValue: value)
        }

        let rawValue: String

        init(rawValue: String) {
            self.rawValue = rawValue
        }

    }

}
