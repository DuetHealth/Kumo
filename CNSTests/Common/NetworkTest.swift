//
//  NetworkTest.swift
//  CNSTests
//
//  Created by ライアン on 3/2/19.
//  Copyright © 2019 Duet Health. All rights reserved.
//

import Foundation
import RxSwift
import XCTest
@testable import CNS

class NetworkTest: XCTestCase {
    
    let service = Service(baseURL: URL(string: "https://httpbin.org")!)
    
    let parameters: (actual: [String: Any], expected: [String: String]) = {
        let base: [String: Any] = ["foo": 1, "bar": "foo"]
        return (actual: base, expected: base.mapValues(String.init(describing:)))
    }()
    
    func successfulTest<T>(of observable: Observable<T>, file: StaticString = #file, line: UInt = #line, function: String = #function) -> (_ description: String) -> ((_ successCondition: @escaping (T) -> Bool) -> ()) {
        return { description in
            { successCondition in
                var emissions = [T]()
                let expect = self.expectation(description: description)
                _ = observable
                    .subscribe(onNext: {
                        emissions.append($0)
                    }, onError: { error in
                        XCTFail("Expectation violated: test '\(function)' emitted an error.", file: file, line: line)
                        expect.fulfill()
                    }, onCompleted: {
                        XCTAssertTrue(emissions.count == 1, "The sequence emitted more than one element.", file: file, line: line)
                        XCTAssertTrue(successCondition(emissions.first!), "Expectation violated: '\(description)'", file: file, line: line)
                        expect.fulfill()
                    })
                self.wait(for: [expect], timeout: 10)
            }
        }
    }
    
    func erroringTest<T>(of observable: Observable<T>,  file: StaticString = #file, line: UInt = #line, function: String = #function) -> (_ description: String) -> ((_ successCondition: @escaping (Error) -> Bool) -> ()) {
        return { description in
            { successCondition in
                let expect = self.expectation(description: description)
                _ = observable
                    .subscribe(onNext: { _ in
                        XCTFail("Expectation violated: test '\(function)' emitted an element.", file: file, line: line)
                        expect.fulfill()
                    }, onError: { error in
                        XCTAssertTrue(successCondition(error), "Expectation violated: '\(description)'", file: file, line: line)
                        expect.fulfill()
                    }, onCompleted: {
                        XCTFail("Expectation violated: test '\(function)' completed.", file: file, line: line)
                        expect.fulfill()
                    })
                self.wait(for: [expect], timeout: 10)
            }
        }
    }
    
}
