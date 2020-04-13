import Foundation
import RxSwift
import XCTest
@testable import Kumo

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
        _ = cache.fetch(from: url)
            .subscribe(onNext: { (result: Data) in
                data = result
            }, onError: { error in
                XCTFail("Fetching encountered an error: \(error)")
            }, onCompleted: {
                XCTAssert(self.cache.contains(url), "Expected the cache to contain URL '\(url)'")
                self.cache.cleanImmediately()
                XCTAssert(data != nil, "Expected data to eventually be fetched, but none was received.")
            })
    }

    func testSubsequentCacheCallReturnsData() {
        cache.persistentStorageHeuristics.cleansIndiscriminately = true
        let url = URL(string: "https://httpbin.org/bytes/1024")!
        var data = Data?.none
        XCTAssert(!cache.contains(url), "Expected the cache to be empty but contained the URL '\(url)'")
        _ = cache.fetch(from: url)
            .flatMap { (_: Data) in self.cache.fetch(from: url) }
            .subscribe(onNext: { (result: Data) in
                data = result
            }, onError: { error in
                XCTFail("Fetching encountered an error: \(error)")
            }, onCompleted: {
                XCTAssert(self.cache.contains(url), "Expected the cache to contain URL '\(url)'")
                self.cache.cleanImmediately()
                XCTAssert(data != nil, "Expected data to eventually be fetched, but none was received.")
            })
    }

}
