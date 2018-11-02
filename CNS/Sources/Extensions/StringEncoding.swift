//
//  StringEncoding.swift
//  CNS
//
//  Created by ライアン on 11/1/18.
//  Copyright © 2018 Duet Health. All rights reserved.
//

import Foundation

public extension String.Encoding {
    
    public var stringValue: String? {
        return CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(rawValue)) as String?
    }
    
}
