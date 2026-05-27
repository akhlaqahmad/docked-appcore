import Foundation
import Observation

@MainActor
@Observable
public final class DockInspectorViewModel {
    public let dockID: UUID
    public var lastError: String?

    private let manager: DockManager

    public init(dockID: UUID, manager: DockManager) {
        self.dockID = dockID
        self.manager = manager
    }

    public var dock: Dock? {
        manager.library.docks.first { $0.id == dockID }
    }

    public func setIconSize(_ value: CGFloat) {
        update { $0.iconSize = value }
    }

    public func setSpacing(_ value: CGFloat) {
        update { $0.spacing = value }
    }

    public func setOpacity(_ value: Double) {
        update { $0.opacity = value }
    }

    public func setCornerRadius(_ value: CGFloat) {
        update { $0.cornerRadius = value }
    }

    public func setTheme(_ theme: ThemeID) {
        update { $0.theme = theme }
    }

    public func setBlur(_ material: VisualMaterial) {
        update { $0.blurMaterial = material }
    }

    public func toggleMagnification(_ enabled: Bool) {
        update { $0.magnification.enabled = enabled }
    }

    public func setAutoHide(_ mode: DockBehavior.AutoHide) {
        do {
            try manager.updateBehavior(dockID: dockID) { $0.autoHide = mode }
        } catch {
            lastError = error.localizedDescription
        }
    }

    private func update(_ transform: (inout DockAppearance) -> Void) {
        do {
            try manager.updateAppearance(dockID: dockID, transform)
        } catch {
            lastError = error.localizedDescription
        }
    }
}
