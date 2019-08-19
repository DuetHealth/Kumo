import Foundation

struct ExtendedAttributeKey: Hashable, RawRepresentable {
    typealias RawValue = String

    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }

}

extension FileManager {

    struct ExtendedAttributeError: Error {
        let localizedDescription = String(utf8String: strerror(errno))
    }

    func setExtendedAttributes(_ attributes: [ExtendedAttributeKey: Data], ofItemAtPath path: String) throws {
        try attributes.forEach {
            try setExtendedAttribute($0.key, value: $0.value, ofItemAtPath: path)
        }
    }

    func setExtendedAttributes<D: DirectThrowingDataConvertible>(_ attributes: [ExtendedAttributeKey: D], ofItemAtPath path: String) throws {
        try attributes.forEach {
            try setExtendedAttribute($0.key, value: $0.value.data(), ofItemAtPath: path)
        }
    }

    func setExtendedAttribute<D: DirectThrowingDataConvertible>(_ key: ExtendedAttributeKey, value: D, ofItemAtPath path: String) throws {
        let data = try value.data()
        if setxattr(path, key.rawValue, (data as NSData).bytes, data.count, 0, 0) != 0 { throw ExtendedAttributeError() }
    }

    func setExtendedAttribute(_ key: ExtendedAttributeKey, value: Data, ofItemAtPath path: String) throws {
        if setxattr(path, key.rawValue, (value as NSData).bytes, value.count, 0, 0) != 0 {
            throw ExtendedAttributeError()
        }
    }

    func valueForExtendedAttribute(_ key: ExtendedAttributeKey, ofItemAtPath path: String) throws -> Data {
        let count = getxattr(path, key.rawValue, nil, 0, 0, 0)
        guard count != -1, let buffer = malloc(count), getxattr(path, key.rawValue, buffer, count, 0, 0) != -1 else {
            throw ExtendedAttributeError()
        }
        return Data(bytes: buffer, count: count)
    }

    func valueForExtendedAttribute<D: DirectThrowingDataRepresentable>(_ key: ExtendedAttributeKey, ofItemAtPath path: String) throws -> D {
        return try D.init(data: valueForExtendedAttribute(key, ofItemAtPath: path))
    }

}
