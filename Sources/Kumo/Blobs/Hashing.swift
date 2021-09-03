import CryptoKit
import Foundation

extension Digest {

    var hexString: String {
        compactMap { String(format: "%02x", $0) }
            .joined()
    }

}

/// A method for generating a key to be used to resolve cache requests.
public enum CachePathResolver {

    /// MD5 (message-digest algorithm).
    /// - Remark: Not the best algorithm to use and can create collisions.
    case md5

    /// SHA-1 (Secure Hash Algorithm 1).
    case sha1

    /// SHA-256 (256-bit Secure Hash Algorithm 2).
    case sha256

    /// SHA-384 (384-bit Secure Hash Algorithm 2).
    case sha384

    /// SHA-512 (512-bit Secure Hash Algorithm 2).
    case sha512

    /// A custom algorithm for hashing data to a unique key. Must be
    /// deterministic and nearly collision-free for caching to function
    /// properly.
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
