import Foundation
import RxSwift

extension Reactive where Base: Progress {
    
    var fractionComplete: Observable<Double> {
        return Observable<Double>.create { observer in
            let observation = self.base.observe(\Base.fractionCompleted) { (base, _) in
                observer.onNext(base.fractionCompleted)
            }
            return Disposables.create(with: observation.invalidate)
        }
    }
    
}
