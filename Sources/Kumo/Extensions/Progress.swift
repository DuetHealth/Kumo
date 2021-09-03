import Combine
import Foundation

extension _KumoNamespace where Base: Progress {
    var fractionComplete: AnyPublisher<Double, Never> {
        base.publisher(for: \.fractionCompleted)
            .eraseToAnyPublisher()
    }
}
