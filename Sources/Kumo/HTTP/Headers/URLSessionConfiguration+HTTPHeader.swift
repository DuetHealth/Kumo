import Foundation

#if canImport(KumoCoding)
import KumoCoding
#endif

public extension URLSessionConfiguration {

    struct CommonHTTPHeaders {

        public let base: URLSessionConfiguration

        public init(_ base: URLSessionConfiguration) {
            self.base = base
        }

        public func set(authorization: Authorization) {
            set(value: authorization.value, for: .authorization)
        }

        public func set(accept: MIMEType) {
            set(value: accept.rawValue, for: .accept)
        }

        public func set(contentType: MIMEType) {
            set(value: contentType.rawValue, for: .contentType)
        }

        public func set(value: Any, for header: HTTP.Header) {
            DispatchQueue.global(qos: .userInitiated).sync {
                if base.httpAdditionalHeaders != nil {
                    base.httpAdditionalHeaders![header.rawValue] = value
                } else {
                    base.httpAdditionalHeaders = [header.rawValue: value]
                }
            }
        }

        public func remove(_ header: HTTP.Header) {
            DispatchQueue.global(qos: .userInitiated).sync {
                base.httpAdditionalHeaders?[header.rawValue] = ""
            }
        }

        public subscript(_ header: HTTP.Header) -> Any? {
            get { return base.httpAdditionalHeaders?[header.rawValue] }
            set { newValue.map { set(value: $0, for: header) } ?? remove(header) }
        }

    }

    var headers: CommonHTTPHeaders {
        return CommonHTTPHeaders(self)
    }

    var httpHeaders: [HTTP.Header: Any]? {
        get {
            return httpAdditionalHeaders.map {
                Dictionary(uniqueKeysWithValues: $0.compactMap { pair in
                    guard let string = pair.key.base as? String else { return nil }
                    return (HTTP.Header(rawValue: string), pair.value)
                })
            }
        }
    }

}
