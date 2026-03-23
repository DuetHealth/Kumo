@preconcurrency import Combine
import Foundation
@testable import Kumo
import XCTest

class NetworkTest: XCTestCase {
    let service = Service(baseURL: URL(string: "https://httpbin.org")!, logger: TestLogger())
    
    let parameters: (actual: [String: Any], expected: [String: String]) = {
        let base: [String: Any] = ["foo": 1, "bar": "foo"]
        return (actual: base, expected: base.mapValues(String.init(describing:)))
    }()
    
    func successfulTest<T>(of observable: AnyPublisher<T, Error>, file: StaticString = #filePath, line: UInt = #line, function: String = #function) -> (_ description: String) -> ((_ successCondition: @escaping (T) -> Bool) -> Void) {
        return { description in
            { successCondition in
                var emissions = [T]()
                let expect = self.expectation(description: description)
                observable.sink(receiveCompletion: { completion in
                    switch completion {
                    case let .failure(error):
                        XCTFail("Expectation violated - test '\(function)' emitted an error: \(error).", file: file, line: line)
                        expect.fulfill()
                    case .finished:
                        XCTAssertTrue(emissions.count == 1, "The sequence emitted more than one element.", file: file, line: line)
                        XCTAssertTrue(successCondition(emissions.first!), "Expectation violated - '\(description)'", file: file, line: line)
                        expect.fulfill()
                    }
                }, receiveValue: {
                    emissions.append($0)
                })
                .withLifetime(of: self)
                self.wait(for: [expect], timeout: 10)
            }
        }
    }
    
    func erroringTest<T>(of observable: AnyPublisher<T, Error>, file: StaticString = #filePath, line: UInt = #line, function: String = #function) -> (_ description: String) -> ((_ successCondition: @escaping (Error) -> Bool) -> Void) {
        return { description in
            { successCondition in
                let expect = self.expectation(description: description)
                observable.sink(receiveCompletion: { completion in
                    switch completion {
                    case let .failure(error):
                        XCTAssertTrue(successCondition(error), "Expectation violated - '\(description)'", file: file, line: line)
                        expect.fulfill()
                    case .finished:
                        XCTFail("Expectation violated - test '\(function)' finished.", file: file, line: line)
                        expect.fulfill()
                    }
                }, receiveValue: { element in
                    XCTFail("Expectation violated - test '\(function)' emitted an element: \(element).", file: file, line: line)
                    expect.fulfill()
                })
                .withLifetime(of: self)
                self.wait(for: [expect], timeout: 10)
            }
        }
    }
    
    func perform<T: Decodable & Sendable, Method: _RequestMethod, Resource: _RequestResource, Parameters: _RequestParameters, Body: _RequestBody, Key: _ResponseNestedKey>(_ request: HTTP._Request<Method, Resource, Parameters, Body, Key>) -> AnyPublisher<T, Error> {
        let service = self.service
        return Deferred<AnyPublisher<T, Error>> {
            Future<T, Error> { promise in
                let box = SendableBox(promise)
                Task {
                    do {
                        let result: T = try await service.perform(request)
                        box.value(.success(result))
                    } catch {
                        box.value(.failure(error))
                    }
                }
            }.eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }

    func perform<Method: _RequestMethod, Resource: _RequestResource, Parameters: _RequestParameters, Body: _RequestBody, Key: _ResponseNestedKey>(_ request: HTTP
        ._Request<Method, Resource, Parameters, Body, Key>) -> AnyPublisher<Void, Error> {
        let service = self.service
        return Deferred<AnyPublisher<Void, Error>> {
            Future<Void, Error> { promise in
                let box = SendableBox(promise)
                Task {
                    do {
                        try await service.perform(request) as Void
                        box.value(.success(()))
                    } catch {
                        box.value(.failure(error))
                    }
                }
            }.eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
}

private struct SendableBox<T>: @unchecked Sendable {
    let value: T
    init(_ value: T) { self.value = value }
}
