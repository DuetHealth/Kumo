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

struct FileType: Equatable, Codable {
    
    static func ==(_ lhs: FileType, _ rhs: FileType) -> Bool {
        return lhs.fileExtension == rhs.fileExtension
    }
    
    let fileExtension: String
    let mimeType: String
    let uti: String
    
    init?(uti: String) {
        self.uti = uti
        guard let mimeType = UTTypeCopyPreferredTagWithClass(uti as CFString, kUTTagClassMIMEType) else {
            chron.stdout.warning("UTI \(uti) isn't associated with a MIME type.")
            return nil
        }
        self.mimeType = mimeType.takeRetainedValue() as String
        self.fileExtension = UTTypeCopyPreferredTagWithClass(uti as CFString, kUTTagClassFilenameExtension)?.takeRetainedValue() as String? ?? ""
    }
    
    init?(fileExtension: String) {
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as CFString, nil) else {
            chron.stdout.warning("File extension \(fileExtension) isn't associated with a native UTI.")
            return nil
        }
        self.fileExtension = fileExtension
        self.uti = uti.takeRetainedValue() as String
        guard let mimeType = UTTypeCopyPreferredTagWithClass(self.uti as CFString, kUTTagClassMIMEType) else {
            chron.stdout.warning("File extension \(fileExtension) is associated with native UTI \(uti) but isn't associated with a MIME type.")
            return nil
        }
        self.mimeType = mimeType.takeRetainedValue() as String
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let fileExtension = try container.decode(String.self)
        guard let fileType = FileType(fileExtension: fileExtension) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "The encoded extension does not match an available UTI."))
        }
        self = fileType
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(fileExtension)
    }
    
}

