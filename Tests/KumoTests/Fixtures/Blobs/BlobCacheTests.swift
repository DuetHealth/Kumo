import Combine
import Foundation
@testable import Kumo
import XCTest

class BlobCacheTests: NetworkTest {
    let cache = BlobCache(baseURL: URL(string: "https://httpbin.org")!)

    func testRoutineCacheCallReturnsData() {
        // We clean indiscriminately in testing because we don't want artifacts to
        // carry over multiple tests. We could use a mocking mechanism, but for a
        // first testing pass this is a low-cost solution.
        cache.persistentStorageHeuristics.cleansIndiscriminately = true
        let url = URL(string: "https://httpbin.org/bytes/1024")!
        var data = Data?.none
        XCTAssert(!cache.contains(url), "Expected the cache to be empty but contained the URL '\(url)'")
        cache.fetch(from: url)
            .sink(receiveCompletion: { completion in
                switch completion {
                case let .failure(error):
                    XCTFail("Fetching encountered an error: \(error)")
                case .finished:
                    XCTAssert(self.cache.contains(url), "Expected the cache to contain URL '\(url)'")
                    self.cache.cleanImmediately()
                    XCTAssert(data != nil, "Expected data to eventually be fetched, but none was received.")
                }
            }, receiveValue: { (result: Data) in
                data = result
            })
            .withLifetime(of: self)
    }

    func testSubsequentCacheCallReturnsData() {
        cache.persistentStorageHeuristics.cleansIndiscriminately = true
        let url = URL(string: "https://httpbin.org/bytes/1024")!
        var data = Data?.none
        XCTAssert(!cache.contains(url), "Expected the cache to be empty but contained the URL '\(url)'")
        cache.fetch(from: url)
            .flatMap { (_: Data) in self.cache.fetch(from: url) }
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTFail("Fetching encountered an error: \(error)")
                case .finished:
                    XCTAssert(self.cache.contains(url), "Expected the cache to contain URL '\(url)'")
                    self.cache.cleanImmediately()
                    XCTAssert(data != nil, "Expected data to eventually be fetched, but none was received.")
                }
            }, receiveValue: { (result: Data) in
                data = result
            })
        .withLifetime(of: self)
    }
}
