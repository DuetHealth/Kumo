import Foundation

#if !os(macOS)
import MobileCoreServices
#endif

public struct FileType: Equatable, Codable {
    
    enum AssociationError: Error {
        case noMIMEType
        case noUTI
        case noExtension
    }
    
    public static func ==(_ lhs: FileType, _ rhs: FileType) -> Bool {
        return lhs.fileExtension == rhs.fileExtension
    }
    
    public let fileExtension: String
    public let mimeType: String
    public let uti: String
    
    public init(uti: String) throws {
        self.uti = uti
        guard let mimeType = UTTypeCopyPreferredTagWithClass(uti as CFString, kUTTagClassMIMEType) else { throw AssociationError.noMIMEType }
        self.mimeType = mimeType.takeRetainedValue() as String
        self.fileExtension = UTTypeCopyPreferredTagWithClass(uti as CFString, kUTTagClassFilenameExtension)?.takeRetainedValue() as String? ?? ""
    }
    
    public init(fileExtension: String) throws {
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as CFString, nil) else { throw AssociationError.noUTI }
        self.uti = uti.takeRetainedValue() as String
        guard let mimeType = UTTypeCopyPreferredTagWithClass(self.uti as CFString, kUTTagClassMIMEType) else { throw AssociationError.noMIMEType }
        self.mimeType = mimeType.takeRetainedValue() as String
        self.fileExtension = fileExtension
    }
    
    public init(mimeType: String) throws {
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil) else { throw AssociationError.noUTI }
        self.uti = uti.takeRetainedValue() as String
        self.mimeType = mimeType
        guard let fileExtension = UTTypeCopyPreferredTagWithClass(self.uti as CFString, kUTTagClassFilenameExtension) else { throw AssociationError.noExtension }
        self.fileExtension = fileExtension.takeRetainedValue() as String
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

