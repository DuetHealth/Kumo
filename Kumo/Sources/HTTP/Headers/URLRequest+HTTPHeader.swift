import Foundation

public extension URLRequest {

    var httpHeaders: [HTTPHeader: String]? {
        get {
            return allHTTPHeaderFields.map {
                Dictionary(uniqueKeysWithValues: $0.map { pair in
                    return (HTTPHeader(rawValue: pair.key), pair.value)
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

    mutating func remove(header: HTTPHeader) {
        setValue(nil, forHTTPHeaderField: header.rawValue)
    }

    mutating func set(authorization: Authorization) {
        setValue(authorization.value, forHTTPHeaderField: HTTPHeader.authorization.rawValue)
    }

    mutating func set(accept: MIMEType) {
        setValue(accept.rawValue, forHTTPHeaderField: HTTPHeader.accept.rawValue)
    }

    mutating func set(contentType: MIMEType) {
        setValue(contentType.rawValue, forHTTPHeaderField: HTTPHeader.contentType.rawValue)
    }

    mutating func set(contentLength: Int) {
        setValue("\(contentLength)", forHTTPHeaderField: HTTPHeader.contentLength.rawValue)
    }

    mutating func set(value: String, for header: HTTPHeader) {
        setValue(value, forHTTPHeaderField: header.rawValue)
    }

}
