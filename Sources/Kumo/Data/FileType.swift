import Foundation
import UniformTypeIdentifiers

/// A structure representing information about a file.
public struct FileType: Equatable, Codable {

    enum AssociationError: Error {
        case noMIMEType
        case noUTI
        case noExtension
    }

    public static func ==(_ lhs: FileType, _ rhs: FileType) -> Bool {
        return lhs.fileExtension == rhs.fileExtension
    }

    /// The file's extension.
    public let fileExtension: String

    /// The file's MIME type.
    public let mimeType: String

    /// The file's uniform type identifier.
    public let uti: String

    /// Creates a ``FileType`` object from the given `uti`.
    /// - Parameter uti: A file's uniform type identifier.
    public init(uti: String) throws {
        let type = UTType(uti)
        self.uti = uti
        guard let mimeType = type?.preferredMIMEType else { throw AssociationError.noMIMEType }
        self.mimeType = mimeType
        self.fileExtension = type?.preferredFilenameExtension ?? ""
    }

    /// Creates a ``FileType`` object from the given `fileExtension`.
    /// - Parameter fileExtension: A file's extension.
    public init(fileExtension: String) throws {
        guard let type = UTType(filenameExtension: fileExtension) else { throw AssociationError.noUTI }
        self.uti = type.identifier
        guard let mimeType = type.preferredMIMEType else { throw AssociationError.noMIMEType }
        self.mimeType = mimeType
        self.fileExtension = fileExtension
    }

    /// Creates a ``FileType`` object from the given `mimeType`.
    /// - Parameter mimeType: A file's MIME type.
    public init(mimeType: String) throws {
        guard let type = UTType(mimeType: mimeType) else { throw AssociationError.noUTI }
        self.uti = type.identifier
        self.mimeType = mimeType
        guard let fileExtension = type.preferredFilenameExtension else { throw AssociationError.noExtension }
        self.fileExtension = fileExtension
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let fileExtension = try container.decode(String.self)
        guard let fileType = try? FileType(fileExtension: fileExtension) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "The encoded extension does not match an available UTI."))
        }
        self = fileType
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(fileExtension)
    }

}
