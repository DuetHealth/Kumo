import Foundation
@testable import Kumo
import XCTest

class BlobCacheTests: NetworkTest {
    let cache = BlobCache(baseURL: URL(string: "https://httpbin.org")!)

    func testRoutineCacheCallReturnsData() async throws {
        cache.persistentStorageHeuristics.cleansIndiscriminately = true
        let url = URL(string: "https://httpbin.org/bytes/1024")!
        XCTAssert(!cache.contains(url), "Expected the cache to be empty but contained the URL '\(url)'")
        let data: Data = try await cache.fetch(from: url)
        XCTAssert(cache.contains(url), "Expected the cache to contain URL '\(url)'")
        XCTAssert(!data.isEmpty, "Expected data to eventually be fetched, but none was received.")
        cache.cleanImmediately()
    }

    func testSubsequentCacheCallReturnsData() async throws {
        cache.persistentStorageHeuristics.cleansIndiscriminately = true
        let url = URL(string: "https://httpbin.org/bytes/1024")!
        XCTAssert(!cache.contains(url), "Expected the cache to be empty but contained the URL '\(url)'")
        let _: Data = try await cache.fetch(from: url)
        let data: Data = try await cache.fetch(from: url)
        XCTAssert(cache.contains(url), "Expected the cache to contain URL '\(url)'")
        XCTAssert(!data.isEmpty, "Expected data to eventually be fetched, but none was received.")
        cache.cleanImmediately()
    }
}
