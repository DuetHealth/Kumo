import Foundation
import RxSwift

extension Reactive where Base: Progress {
    
    var fractionComplete: Observable<Double> {
        return observe(Double.self, #keyPath(Progress.fractionCompleted))
            .filter { $0 == nil }
            .map { $0! }
    }
    
}
