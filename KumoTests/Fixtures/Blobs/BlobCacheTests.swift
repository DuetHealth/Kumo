import Foundation
import RxSwift
import XCTest
@testable import Kumo

class BlobCacheTests: XCTestCase {

    let cache = BlobCache(baseURL: URL(string: "https://httpbin.org")!)

    func testCachingEvenWorks() {
        _ = cache.fetch(from: URL(string: "https://httpbin.org/bytes/1024")!)
            .subscribe(onNext: { (image: UIImage) in
                print("image")
            }, onError: { error in
                print(error)
            }, onCompleted: {
                print("bye")
            })
    }

}
