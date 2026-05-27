import Foundation

public struct DockBehavior: Codable, Hashable, Sendable {
    public enum AutoHide: String, Codable, Sendable, CaseIterable {
        case never, onMouseLeave, onFullscreen, always
    }

    public var autoHide: AutoHide
    public var hideOnFullscreen: Bool
    public var clickThrough: Bool
    public var showLabels: Bool
    public var hotkeyToggle: KeyShortcut?

    public init(
        autoHide: AutoHide = .never,
        hideOnFullscreen: Bool = false,
        clickThrough: Bool = false,
        showLabels: Bool = false,
        hotkeyToggle: KeyShortcut? = nil
    ) {
        self.autoHide = autoHide
        self.hideOnFullscreen = hideOnFullscreen
        self.clickThrough = clickThrough
        self.showLabels = showLabels
        self.hotkeyToggle = hotkeyToggle
    }

    public static let `default` = DockBehavior()
}

public struct KeyShortcut: Codable, Hashable, Sendable {
    public var keyCode: UInt16
    public var modifiersRaw: UInt
    public var displayString: String

    public init(keyCode: UInt16, modifiersRaw: UInt, displayString: String) {
        self.keyCode = keyCode
        self.modifiersRaw = modifiersRaw
        self.displayString = displayString
    }
}
