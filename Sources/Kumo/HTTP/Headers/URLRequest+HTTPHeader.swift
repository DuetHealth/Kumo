import Foundation

#if canImport(KumoCoding)
import KumoCoding
#endif

public extension URLRequest {

    var httpHeaders: [HTTP.Header: String]? {
        get {
            return allHTTPHeaderFields.map {
                Dictionary(uniqueKeysWithValues: $0.map { pair in
                    return (HTTP.Header(rawValue: pair.key), pair.value)
                })
            }
        }
        set {
            allHTTPHeaderFields = newValue.map {
                Dictionary(uniqueKeysWithValues: $0.map { pair in
                    return (pair.key.rawValue, pair.value)
                })
            }
        }
    }

    mutating func remove(header: HTTP.Header) {
        setValue(nil, forHTTPHeaderField: header.rawValue)
    }

    mutating func set(authorization: Authorization) {
        setValue(authorization.value, forHTTPHeaderField: HTTP.Header.authorization.rawValue)
    }

    mutating func set(accept: MIMEType) {
        setValue(accept.rawValue, forHTTPHeaderField: HTTP.Header.accept.rawValue)
    }

    mutating func set(contentType: MIMEType) {
        setValue(contentType.rawValue, forHTTPHeaderField: HTTP.Header.contentType.rawValue)
    }

    mutating func set(contentLength: Int) {
        setValue("\(contentLength)", forHTTPHeaderField: HTTP.Header.contentLength.rawValue)
    }

    mutating func set(value: String, for header: HTTP.Header) {
        setValue(value, forHTTPHeaderField: header.rawValue)
    }

}
