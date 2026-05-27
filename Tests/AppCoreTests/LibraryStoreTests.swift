import XCTest
@testable import AppCore

final class LibraryStoreTests: XCTestCase {
    func test_inMemoryRoundtrip() throws {
        let store = InMemoryLibraryStore()
        var lib = Library.empty
        lib.docks.append(Dock(name: "Test"))
        try store.save(lib)
        let loaded = try store.load()
        XCTAssertEqual(loaded.docks.count, 1)
        XCTAssertEqual(loaded.docks.first?.name, "Test")
    }

    func test_fileStoreRoundtrip() throws {
        let tmp = FileManager.default.temporaryDirectory.appendingPathComponent("library-test-\(UUID()).json")
        defer { try? FileManager.default.removeItem(at: tmp) }
        let store = FileLibraryStore(fileURL: tmp)
        var lib = Library.empty
        lib.docks.append(Dock(name: "Persisted"))
        try store.save(lib)
        let loaded = try store.load()
        XCTAssertEqual(loaded.docks.first?.name, "Persisted")
    }

    func test_fileStore_missingFileReturnsEmpty() throws {
        let tmp = FileManager.default.temporaryDirectory.appendingPathComponent("missing-\(UUID()).json")
        let store = FileLibraryStore(fileURL: tmp)
        let loaded = try store.load()
        XCTAssertEqual(loaded.docks.count, 0)
    }
}
