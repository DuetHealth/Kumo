//
//  Copying.swift
//  CNS
//
//  Created by ライアン on 10/29/18.
//  Copyright © 2018 Duet Health. All rights reserved.
//

import Foundation

protocol ImmutableCopying {
    func copy() -> Self
}

protocol MutableCopying: ImmutableCopying {
    associatedtype MutableCopyType
    
    func mutableCopy() -> MutableCopyType
}

extension NSObject: ImmutableCopying { }

extension ImmutableCopying where Self: NSObject {
    
    func copy() -> Self {
        return (self as NSObject).copy() as! Self
    }
    
}
