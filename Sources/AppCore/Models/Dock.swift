import Foundation
import CoreGraphics

public struct Dock: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public var name: String
    public var screenID: ScreenIdentifier?
    public var position: DockPosition
    public var items: [DockItem]
    public var appearance: DockAppearance
    public var behavior: DockBehavior
    public var triggers: [DockTrigger]
    public var isEnabled: Bool
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        screenID: ScreenIdentifier? = nil,
        position: DockPosition = .default,
        items: [DockItem] = [],
        appearance: DockAppearance = .default,
        behavior: DockBehavior = .default,
        triggers: [DockTrigger] = [],
        isEnabled: Bool = true,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.screenID = screenID
        self.position = position
        self.items = items
        self.appearance = appearance
        self.behavior = behavior
        self.triggers = triggers
        self.isEnabled = isEnabled
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct ScreenIdentifier: Codable, Hashable, Sendable {
    public let displayUUID: String
    public let localizedName: String

    public init(displayUUID: String, localizedName: String) {
        self.displayUUID = displayUUID
        self.localizedName = localizedName
    }
}

public struct DockPosition: Codable, Hashable, Sendable {
    public enum Edge: String, Codable, Sendable, CaseIterable {
        case top, bottom, leading, trailing, floating
    }

    public enum Alignment: String, Codable, Sendable, CaseIterable {
        case start, center, end
    }

    public var edge: Edge
    public var alignment: Alignment
    public var offset: DockOffset

    public init(edge: Edge = .bottom, alignment: Alignment = .center, offset: DockOffset = .zero) {
        self.edge = edge
        self.alignment = alignment
        self.offset = offset
    }

    public static let `default` = DockPosition()
}

/// A 2D offset in points. Defined locally rather than reusing `CGPoint`
/// because `CGPoint`'s `Hashable` / `Sendable` conformances are
/// SDK-dependent and unavailable in some macOS 14 SDK builds (notably the
/// one shipped with Xcode 15.4 / GitHub's macos-14 runner). This struct
/// has identical semantics and converts to/from `CGPoint` trivially.
public struct DockOffset: Codable, Hashable, Sendable {
    public var x: CGFloat
    public var y: CGFloat

    public init(x: CGFloat = 0, y: CGFloat = 0) {
        self.x = x
        self.y = y
    }

    public static let zero = DockOffset(x: 0, y: 0)

    public var cgPoint: CGPoint { CGPoint(x: x, y: y) }

    public init(_ point: CGPoint) {
        self.init(x: point.x, y: point.y)
    }
}
