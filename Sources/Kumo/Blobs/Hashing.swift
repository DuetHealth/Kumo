import CryptoKit
import Foundation

extension Digest {

    var hexString: String {
        compactMap { String(format: "%02x", $0) }
            .joined()
    }

}

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
            return Insecure.MD5.hash(data: key).hexString
        case .sha1:
            return Insecure.SHA1.hash(data: key).hexString
        case .sha256:
            return SHA256.hash(data: key).hexString
        case .sha384:
            return SHA384.hash(data: key).hexString
        case .sha512:
            return SHA512.hash(data: key).hexString
        case .custom(let resolver):
            return resolver(key)
        }
    }

}
