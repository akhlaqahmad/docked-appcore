import Foundation
import Observation

public enum DockManagerError: Error, LocalizedError {
    case freeTierDockLimitReached
    case freeTierItemLimitReached
    case dockNotFound

    public var errorDescription: String? {
        switch self {
        case .freeTierDockLimitReached:
            return "Free tier is limited to \(FreeTierLimits.maxDocks) dock. Upgrade to Pro for unlimited docks."
        case .freeTierItemLimitReached:
            return "Free tier is limited to \(FreeTierLimits.maxItemsPerDock) items per dock. Upgrade to Pro for unlimited."
        case .dockNotFound:
            return "Dock not found."
        }
    }
}

@MainActor
@Observable
public final class DockManager {
    public private(set) var library: Library
    public private(set) var license: License

    private let libraryStore: LibraryStoreProtocol
    private let licenseService: LicenseServiceProtocol
    private var saveTask: Task<Void, Never>?

    public init(
        libraryStore: LibraryStoreProtocol,
        licenseService: LicenseServiceProtocol
    ) {
        self.libraryStore = libraryStore
        self.licenseService = licenseService
        self.library = (try? libraryStore.load()) ?? .empty
        self.license = licenseService.currentLicense()
    }

    // MARK: - Dock CRUD

    public func createDock(name: String, screenID: ScreenIdentifier?) throws -> Dock {
        if !license.isPro && library.docks.count >= FreeTierLimits.maxDocks {
            throw DockManagerError.freeTierDockLimitReached
        }
        let dock = Dock(name: name, screenID: screenID)
        library.docks.append(dock)
        persistDebounced()
        return dock
    }

    public func deleteDock(id: UUID) throws {
        guard library.docks.contains(where: { $0.id == id }) else { throw DockManagerError.dockNotFound }
        library.docks.removeAll { $0.id == id }
        persistDebounced()
    }

    public func renameDock(id: UUID, to newName: String) throws {
        guard let idx = library.docks.firstIndex(where: { $0.id == id }) else { throw DockManagerError.dockNotFound }
        library.docks[idx].name = newName
        library.docks[idx].updatedAt = .now
        persistDebounced()
    }

    public func updateAppearance(dockID: UUID, _ transform: (inout DockAppearance) -> Void) throws {
        guard let idx = library.docks.firstIndex(where: { $0.id == dockID }) else { throw DockManagerError.dockNotFound }
        transform(&library.docks[idx].appearance)
        library.docks[idx].updatedAt = .now
        persistDebounced()
    }

    public func updateBehavior(dockID: UUID, _ transform: (inout DockBehavior) -> Void) throws {
        guard let idx = library.docks.firstIndex(where: { $0.id == dockID }) else { throw DockManagerError.dockNotFound }
        transform(&library.docks[idx].behavior)
        library.docks[idx].updatedAt = .now
        persistDebounced()
    }

    public func setScreen(dockID: UUID, screenID: ScreenIdentifier?) throws {
        guard let idx = library.docks.firstIndex(where: { $0.id == dockID }) else { throw DockManagerError.dockNotFound }
        library.docks[idx].screenID = screenID
        library.docks[idx].updatedAt = .now
        persistDebounced()
    }

    // MARK: - Item CRUD

    public func addItem(_ item: DockItem, to dockID: UUID) throws {
        guard let idx = library.docks.firstIndex(where: { $0.id == dockID }) else { throw DockManagerError.dockNotFound }
        if !license.isPro && library.docks[idx].items.count >= FreeTierLimits.maxItemsPerDock {
            throw DockManagerError.freeTierItemLimitReached
        }
        library.docks[idx].items.append(item)
        library.docks[idx].updatedAt = .now
        persistDebounced()
    }

    public func removeItem(itemID: UUID, from dockID: UUID) throws {
        guard let idx = library.docks.firstIndex(where: { $0.id == dockID }) else { throw DockManagerError.dockNotFound }
        library.docks[idx].items.removeAll { $0.id == itemID }
        library.docks[idx].updatedAt = .now
        persistDebounced()
    }

    public func reorderItems(in dockID: UUID, from source: IndexSet, to destination: Int) throws {
        guard let idx = library.docks.firstIndex(where: { $0.id == dockID }) else { throw DockManagerError.dockNotFound }
        // SwiftUI's `Array.move(fromOffsets:toOffset:)` is a SwiftUI extension and
        // AppCore must stay AppKit/UIKit/SwiftUI-free. Reimplement the same semantics:
        // 1. capture the items to move (in original order)
        // 2. compute the destination index after removals
        // 3. remove from highest index first, then insert as a block
        let movingItems = source.map { library.docks[idx].items[$0] }
        let adjustedDestination = destination - source.filter { $0 < destination }.count
        for offset in source.reversed() {
            library.docks[idx].items.remove(at: offset)
        }
        library.docks[idx].items.insert(contentsOf: movingItems, at: adjustedDestination)
        library.docks[idx].updatedAt = .now
        persistDebounced()
    }

    // MARK: - License sync

    public func refreshLicense() {
        license = licenseService.currentLicense()
    }

    // MARK: - Persistence

    private func persistDebounced() {
        saveTask?.cancel()
        let snapshot = library
        saveTask = Task { [libraryStore] in
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            try? libraryStore.save(snapshot)
        }
    }
}
