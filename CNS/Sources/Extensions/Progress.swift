//
//  Progress.swift
//  CNS
//
//  Created by ライアン on 11/13/18.
//  Copyright © 2018 Duet Health. All rights reserved.
//

import Foundation
import RxSwift

extension Reactive where Base: Progress {
    
    var fractionComplete: Observable<Double> {
        return observe(Double.self, #keyPath(Progress.fractionCompleted))
            .filterNil()
    }
    
}
