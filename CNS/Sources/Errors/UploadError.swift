//
//  UploadError.swift
//  CNS
//
//  Created by ライアン on 11/1/18.
//  Copyright © 2018 Duet Health. All rights reserved.
//

import Foundation

public enum UploadError: Error {
    case notAFileURL(URL)
    case unknownFileType(URL)
    case cannotEncodeFormDataKey(String, encoding: String.Encoding)
    case cannotEncodeMIMEType(String, encoding: String.Encoding)
    
    public var localizedDescription: String {
        switch self {
        case .notAFileURL(let url):
            return "Uploading expects a file URL, but was given \(url)."
        case .unknownFileType(let url):
            return "The type of the file located at path \(url) could not be determined."
        case .cannotEncodeFormDataKey(let key, encoding: let encoding):
            return "The key \(key) cannot be represented with \(encoding)."
        case .cannotEncodeMIMEType(let type, encoding: let encoding):
            return "The MIME type \(type) cannot be represented with \(encoding)."
        }
    }
    
}
