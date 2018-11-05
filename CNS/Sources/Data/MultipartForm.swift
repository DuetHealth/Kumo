//
//  MultipartForm.swift
//  CNS
//
//  Created by ライアン on 11/1/18.
//  Copyright © 2018 Duet Health. All rights reserved.
//

import Foundation

fileprivate var crlf: String {
    return "\r\n"
}

fileprivate func crlf(_ encoding: String.Encoding) -> Data {
    return crlf.data(using: encoding)!
}

public struct MultipartForm {
    
    public let encoding: String.Encoding
    let boundary = String(format: "----com.Duet.CNS%08X%08X", arc4random(), arc4random())
    
    public var data: Data {
        return currentFormData
            + "--\(boundary)--".data(using: .utf8)!
    }
    
    private var currentFormData = Data()
    
    init(encoding: String.Encoding) {
        self.encoding = encoding
    }
    
    init(file: URL, under key: String, encoding: String.Encoding) throws {
        self.encoding = encoding
        try addFile(from: file, under: key)
    }
    
    mutating func addFile(from url: URL, under key: String) throws {
        guard let fileType = FileType(fileExtension: url.pathExtension) else {
            throw UploadError.unknownFileType(url)
        }
        let disposition = try self.disposition(key: key, fileName: url.lastPathComponent)
        let contentType = try self.contentType(mimeType: fileType.mimeType)
        let fileData = try Data(contentsOf: url)
        currentFormData += "--\(boundary)\(crlf)".data(using: encoding)!
            + disposition
            + contentType
            + crlf(encoding)
            + fileData
            + crlf(encoding)
    }
    
    private func disposition(key: String, fileName: String) throws -> Data {
        guard let disposition = "Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(fileName)\"\(crlf)".data(using: encoding) else {
            throw UploadError.cannotEncodeFormDataKey(key, encoding: encoding)
        }
        return disposition
    }
    
    private func contentType(mimeType: String) throws -> Data {
        guard let contentType = "Content-Type: \(mimeType)".data(using: encoding) else {
            throw UploadError.cannotEncodeMIMEType(mimeType, encoding: encoding)
        }
        return contentType
    }
    
}
