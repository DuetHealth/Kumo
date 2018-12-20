//
//  FileType.swift
//  CNS
//
//  Created by ライアン on 11/1/18.
//  Copyright © 2018 Duet Health. All rights reserved.
//

import Chronicle
import Foundation
import MobileCoreServices

public struct FileType: Equatable, Codable {
    
    public static func ==(_ lhs: FileType, _ rhs: FileType) -> Bool {
        return lhs.fileExtension == rhs.fileExtension
    }
    
    public let fileExtension: String
    public let mimeType: String
    public let uti: String
    
    public init?(uti: String) {
        self.uti = uti
        guard let mimeType = UTTypeCopyPreferredTagWithClass(uti as CFString, kUTTagClassMIMEType) else {
            chron.stdout.warning("UTI \(uti) isn't associated with a MIME type.")
            return nil
        }
        self.mimeType = mimeType.takeRetainedValue() as String
        self.fileExtension = UTTypeCopyPreferredTagWithClass(uti as CFString, kUTTagClassFilenameExtension)?.takeRetainedValue() as String? ?? ""
    }
    
    public init?(fileExtension: String) {
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as CFString, nil) else {
            chron.stdout.warning("File extension '\(fileExtension)' isn't associated with a native UTI.")
            return nil
        }
        self.uti = uti.takeRetainedValue() as String
        guard let mimeType = UTTypeCopyPreferredTagWithClass(self.uti as CFString, kUTTagClassMIMEType) else {
            chron.stdout.warning("File extension '\(fileExtension)' is associated with native UTI '\(uti)' but isn't associated with a MIME type.")
            return nil
        }
        self.mimeType = mimeType.takeRetainedValue() as String
        self.fileExtension = fileExtension
    }
    
    public init?(mimeType: String) {
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil) else {
            chron.stdout.warning("MIME type '\(mimeType)' isn't associated with a native UTI.")
            return nil
        }
        self.uti = uti.takeRetainedValue() as String
        self.mimeType = mimeType
        guard let fileExtension = UTTypeCopyPreferredTagWithClass(self.uti as CFString, kUTTagClassFilenameExtension) else {
            chron.stdout.warning("MIME type '\(mimeType)' is associated with native UTI '\(uti)' but isn't associated with a file extension.")
            return nil
        }
        self.fileExtension = fileExtension.takeRetainedValue() as String
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let fileExtension = try container.decode(String.self)
        guard let fileType = FileType(fileExtension: fileExtension) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "The encoded extension does not match an available UTI."))
        }
        self = fileType
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(fileExtension)
    }
    
}

