//
//  MIMEType.swift
//  CNS
//
//  Created by ライアン on 11/1/18.
//  Copyright © 2018 Duet Health. All rights reserved.
//

import Foundation

public struct MIMEType: RawRepresentable {
    public typealias RawValue = String
    
    public static func applicationJSON(charset: String.Encoding = .utf8) -> MIMEType {
        let charsetString = charset.stringValue.map { "; charset=\($0)" } ?? ""
        return MIMEType("application/json\(charsetString)")
    }
    
    public static func multipartFormData(boundary: String) -> MIMEType {
        return MIMEType("multipart/form-data; boundary=\(boundary)")
    }
    
    public let rawValue: String
    
    public init?(rawValue: String) {
        fatalError("NOT YET IMPLEMENTED")
    }
    
    private init(_ value: String) {
        self.rawValue = value
    }
    
}
