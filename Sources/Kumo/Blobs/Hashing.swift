import Foundation
import CryptoKit
import CommonCrypto

public enum CachePathResolver {

    case md5
    case sha1
    case sha256
    case sha384
    case sha512
    case custom((Data) -> String)

    func path(for key: String) -> String {
        path(for: Data(key.utf8))
    }

    func path(for key: Data) -> String {
        switch self {
        case .md5:
            if #available(iOS 13.0, OSX 10.15, *) {
                return Insecure.MD5.hash(data: key).hexString
            } else {
                return Legacy.Insecure.MD5.hash(data: key).hexString
            }
        case .sha1:
            if #available(iOS 13.0, OSX 10.15, *) {
                return Insecure.SHA1.hash(data: key).hexString
            } else {
                return Legacy.Insecure.SHA1.hash(data: key).hexString
            }
        case .sha256:
            if #available(iOS 13.0, OSX 10.15, *) {
                return SHA256.hash(data: key).hexString
            } else {
                return Legacy.SHA256.hash(data: key).hexString
            }
        case .sha384:
            if #available(iOS 13.0, OSX 10.15, *) {
                return SHA384.hash(data: key).hexString
            } else {
                return Legacy.SHA384.hash(data: key).hexString
            }
        case .sha512:
            if #available(iOS 13.0, OSX 10.15, *) {
                return SHA512.hash(data: key).hexString
            } else {
                return Legacy.SHA512.hash(data: key).hexString
            }
        case .custom(let resolver):
            return resolver(key)
        }
    }

}

extension Sequence where Element == UInt8 {

    var hexString: String {
        compactMap { String(format: "%02x", $0) }
            .joined()
    }

}

fileprivate enum Legacy {

    enum Insecure {

        enum MD5 {
            static func hash(data: Data) -> Data {
                var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
                data.withUnsafeBytes {
                    _ = CC_MD5($0.baseAddress, CC_LONG(data.count), &hash)
                }
                return Data(hash)
            }
        }

        enum SHA1 {
            static func hash(data: Data) -> Data {
                var hash = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
                data.withUnsafeBytes {
                    _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &hash)
                }
                return Data(hash)
            }
        }

    }

    enum SHA256 {
        static func hash(data: Data) -> Data {
            var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
            data.withUnsafeBytes {
                _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
            }
            return Data(hash)
        }
    }

    enum SHA384 {
        static func hash(data: Data) -> Data {
            var hash = [UInt8](repeating: 0, count: Int(CC_SHA384_DIGEST_LENGTH))
            data.withUnsafeBytes {
                _ = CC_SHA384($0.baseAddress, CC_LONG(data.count), &hash)
            }
            return Data(hash)
        }
    }

    enum SHA512 {
        static func hash(data: Data) -> Data {
            var hash = [UInt8](repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))
            data.withUnsafeBytes {
                _ = CC_SHA512($0.baseAddress, CC_LONG(data.count), &hash)
            }
            return Data(hash)
        }
    }

}
