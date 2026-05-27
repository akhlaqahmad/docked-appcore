import Foundation
import Observation

@MainActor
@Observable
public final class DockListViewModel {
    public var docks: [Dock] { manager.library.docks }
    public var selectedDockID: UUID?
    public var lastError: String?

    private let manager: DockManager

    public init(manager: DockManager) {
        self.manager = manager
        self.selectedDockID = manager.library.docks.first?.id
    }

    public func createDock(named name: String, screenID: ScreenIdentifier?) {
        do {
            let dock = try manager.createDock(name: name, screenID: screenID)
            selectedDockID = dock.id
        } catch {
            lastError = error.localizedDescription
        }
    }

    public func deleteSelected() {
        guard let id = selectedDockID else { return }
        do {
            try manager.deleteDock(id: id)
            selectedDockID = manager.library.docks.first?.id
        } catch {
            lastError = error.localizedDescription
        }
    }

    public func rename(_ id: UUID, to newName: String) {
        do { try manager.renameDock(id: id, to: newName) } catch { lastError = error.localizedDescription }
    }

    public func selectedDock() -> Dock? {
        guard let id = selectedDockID else { return nil }
        return manager.library.docks.first { $0.id == id }
    }
}
