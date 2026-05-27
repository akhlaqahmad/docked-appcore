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
    public var offset: CGPoint

    public init(edge: Edge = .bottom, alignment: Alignment = .center, offset: CGPoint = .zero) {
        self.edge = edge
        self.alignment = alignment
        self.offset = offset
    }

    public static let `default` = DockPosition()
}
