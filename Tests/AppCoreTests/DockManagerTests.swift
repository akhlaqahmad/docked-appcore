import XCTest
@testable import AppCore

@MainActor
final class DockManagerTests: XCTestCase {
    private func makeManager(license: License = .free) -> DockManager {
        let store = InMemoryLibraryStore()
        let licenseService = StubLicenseService(license: license)
        return DockManager(libraryStore: store, licenseService: licenseService)
    }

    func test_freeTier_limitsToOneDock() throws {
        let manager = makeManager(license: .free)
        _ = try manager.createDock(name: "First", screenID: nil)
        XCTAssertThrowsError(try manager.createDock(name: "Second", screenID: nil)) { error in
            XCTAssertEqual(error as? DockManagerError, .freeTierDockLimitReached)
        }
    }

    func test_proTier_allowsManyDocks() throws {
        let manager = makeManager(license: License(tier: .lifetime, entitlements: License.entitlements(for: .lifetime)))
        _ = try manager.createDock(name: "A", screenID: nil)
        _ = try manager.createDock(name: "B", screenID: nil)
        _ = try manager.createDock(name: "C", screenID: nil)
        XCTAssertEqual(manager.library.docks.count, 3)
    }

    func test_freeTier_limitsItemsPerDock() throws {
        let manager = makeManager(license: .free)
        let dock = try manager.createDock(name: "X", screenID: nil)
        for i in 0..<FreeTierLimits.maxItemsPerDock {
            try manager.addItem(.spacer(SpacerItem(size: CGFloat(i))), to: dock.id)
        }
        XCTAssertThrowsError(try manager.addItem(.spacer(SpacerItem()), to: dock.id)) { error in
            XCTAssertEqual(error as? DockManagerError, .freeTierItemLimitReached)
        }
    }

    func test_renameDock_persists() throws {
        let manager = makeManager(license: .free)
        let dock = try manager.createDock(name: "Old", screenID: nil)
        try manager.renameDock(id: dock.id, to: "New")
        XCTAssertEqual(manager.library.docks.first?.name, "New")
    }

    func test_appearanceUpdate_mutatesDock() throws {
        let manager = makeManager(license: License(tier: .lifetime, entitlements: License.entitlements(for: .lifetime)))
        let dock = try manager.createDock(name: "X", screenID: nil)
        try manager.updateAppearance(dockID: dock.id) { $0.iconSize = 96 }
        XCTAssertEqual(manager.library.docks.first?.appearance.iconSize, 96)
    }
}

private final class StubLicenseService: LicenseServiceProtocol, @unchecked Sendable {
    let lock = NSLock()
    var license: License
    init(license: License) { self.license = license }
    func currentLicense() -> License { lock.lock(); defer { lock.unlock() }; return license }
    func activate(key: String) async throws -> License { license }
    func deactivate() async throws { license = .free }
    func refresh() async throws -> License { license }
}
