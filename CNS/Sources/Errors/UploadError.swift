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
    case cannotEncodeFormData(name: String, encoding: String.Encoding)
    
    public var localizedDescription: String {
        switch self {
        case .notAFileURL(let url):
            return "Uploading expects a file URL, but was given \(url)."
        case .unknownFileType(let url):
            return "The type of the file located at path \(url) could not be determined."
        case .cannotEncodeFormData(name: let name, encoding: let encoding):
            return "The name \(name) cannot be represented with \(encoding)."
        }
    }
    
}
