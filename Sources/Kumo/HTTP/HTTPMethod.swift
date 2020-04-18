import Foundation

@available(*, deprecated, renamed: "HTTP.Method")
typealias HTTPMethod = HTTP.Method

public extension HTTP {

    enum Method: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
        case head = "HEAD"
    }

}
