import Foundation
import CoreGraphics

public struct DockAppearance: Codable, Hashable, Sendable {
    public var iconSize: CGFloat
    public var spacing: CGFloat
    public var paddingHorizontal: CGFloat
    public var paddingVertical: CGFloat
    public var cornerRadius: CGFloat
    public var opacity: Double
    public var blurMaterial: VisualMaterial
    public var border: DockBorderStyle?
    public var shadow: DockShadowStyle?
    public var magnification: MagnificationStyle
    public var theme: ThemeID

    public init(
        iconSize: CGFloat = 48,
        spacing: CGFloat = 8,
        paddingHorizontal: CGFloat = 14,
        paddingVertical: CGFloat = 10,
        cornerRadius: CGFloat = 16,
        opacity: Double = 0.94,
        blurMaterial: VisualMaterial = .hudWindow,
        border: DockBorderStyle? = .default,
        shadow: DockShadowStyle? = .default,
        magnification: MagnificationStyle = .default,
        theme: ThemeID = .glass
    ) {
        self.iconSize = iconSize
        self.spacing = spacing
        self.paddingHorizontal = paddingHorizontal
        self.paddingVertical = paddingVertical
        self.cornerRadius = cornerRadius
        self.opacity = opacity
        self.blurMaterial = blurMaterial
        self.border = border
        self.shadow = shadow
        self.magnification = magnification
        self.theme = theme
    }

    public static let `default` = DockAppearance()
}

public enum VisualMaterial: String, Codable, Sendable, CaseIterable {
    case hudWindow, popover, sidebar, windowBackground, contentBackground, fullScreenUI, titlebar, menu, headerView, sheet
}

public struct DockBorderStyle: Codable, Hashable, Sendable {
    public var width: CGFloat
    public var colorHex: String
    public var inset: Bool

    public init(width: CGFloat = 0.5, colorHex: String = "#FFFFFF14", inset: Bool = true) {
        self.width = width
        self.colorHex = colorHex
        self.inset = inset
    }

    public static let `default` = DockBorderStyle()
}

public struct DockShadowStyle: Codable, Hashable, Sendable {
    public var radius: CGFloat
    public var x: CGFloat
    public var y: CGFloat
    public var colorHex: String

    public init(radius: CGFloat = 24, x: CGFloat = 0, y: CGFloat = 8, colorHex: String = "#00000052") {
        self.radius = radius
        self.x = x
        self.y = y
        self.colorHex = colorHex
    }

    public static let `default` = DockShadowStyle()
}

public struct MagnificationStyle: Codable, Hashable, Sendable {
    public var enabled: Bool
    public var scale: CGFloat
    public var radius: CGFloat

    public init(enabled: Bool = true, scale: CGFloat = 1.6, radius: CGFloat = 60) {
        self.enabled = enabled
        self.scale = scale
        self.radius = radius
    }

    public static let `default` = MagnificationStyle()
}

public enum ThemeID: String, Codable, Sendable, CaseIterable {
    case glass, stark, minimal, glow, mono, custom
}
