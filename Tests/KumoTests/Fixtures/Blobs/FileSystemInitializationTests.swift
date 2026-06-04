import Foundation
@testable import Kumo
import XCTest

final class FileSystemInitializationTests: XCTestCase {

    func testInitDoesNotTrapWhenDirectoryCreationReturnsFileExists() {
        let backingManager = FileExistsErrorFileManager()
        let parentDirectory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)

        XCTAssertNoThrow(FileSystem(backingManager: backingManager, parentDirectory: parentDirectory))
    }

    func testInitIsIdempotentWhenParentDirectoryAlreadyExists() throws {
        let backingManager = FileManager.default
        let parentDirectory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)

        try backingManager.createDirectory(at: parentDirectory, withIntermediateDirectories: true, attributes: nil)
        defer { try? backingManager.removeItem(at: parentDirectory) }

        XCTAssertNoThrow(FileSystem(backingManager: backingManager, parentDirectory: parentDirectory))
        XCTAssertNoThrow(FileSystem(backingManager: backingManager, parentDirectory: parentDirectory))
    }
}

private final class FileExistsErrorFileManager: FileManager {
    override func createDirectory(
        at url: URL,
        withIntermediateDirectories createIntermediates: Bool,
        attributes: [FileAttributeKey: Any]? = nil
    ) throws {
        throw NSError(domain: NSCocoaErrorDomain, code: 516)
    }
}
