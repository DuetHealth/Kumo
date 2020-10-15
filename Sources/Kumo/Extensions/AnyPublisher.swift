import Combine
import Foundation

// https://stackoverflow.com/a/61035663/104527
struct AnyObserver<Output, Failure: Error> {
    let onNext: ((Output) -> Void)
    let onError: ((Failure) -> Void)
    let onComplete: (() -> Void)
}

struct Disposable {
    let dispose: () -> Void
}

extension AnyPublisher {
    static func create(subscribe: @escaping (AnyObserver<Output, Failure>) -> AnyCancellable) -> Self {
        let subject = PassthroughSubject<Output, Failure>()
        var cancellable: AnyCancellable?
        return subject
            .handleEvents(receiveSubscription: { subscription in
                cancellable = subscribe(AnyObserver(
                    onNext: { output in subject.send(output) },
                    onError: { failure in subject.send(completion: .failure(failure)) },
                    onComplete: { subject.send(completion: .finished) }
                ))
            }, receiveCancel: { cancellable?.cancel() })
            .eraseToAnyPublisher()
    }
}
