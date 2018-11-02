//
//  MultipartForm.swift
//  CNS
//
//  Created by ライアン on 11/1/18.
//  Copyright © 2018 Duet Health. All rights reserved.
//

import Foundation

public struct MultipartForm {
    
    public let encoding: String.Encoding
    let boundary = String(format: "----comDuetCNS%08X%08X", arc4random(), arc4random())
    
    public var data: Data {
        return currentFormData
            + "--\(boundary)--".data(using: .utf8)!
    }
    
    private var currentFormData = Data()
    
    init(encoding: String.Encoding) {
        self.encoding = encoding
    }
    
    init(name: String, fileData: Data, encoding: String.Encoding) throws {
        self.encoding = encoding
        try addFile(name: name, fileData: fileData)
    }
    
    mutating func addFile(name: String, fileData: Data) throws {
        guard let disposition = "Content-Disposition: form-data; name=\"\(name)\\r\n".data(using: encoding) else {
            throw UploadError.cannotEncodeFormData(name: name, encoding: encoding)
        }
        currentFormData += "--\(boundary)\r\n".data(using: encoding)!
            + disposition
            + fileData
    }
    
}
