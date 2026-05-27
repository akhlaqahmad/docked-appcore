import Foundation

public struct Library: Codable, Sendable {
    public static let currentSchemaVersion = 1

    public var schemaVersion: Int
    public var docks: [Dock]
    public var globalHotkeys: [KeyShortcut]
    public var lastModified: Date

    public init(
        schemaVersion: Int = Library.currentSchemaVersion,
        docks: [Dock] = [],
        globalHotkeys: [KeyShortcut] = [],
        lastModified: Date = .now
    ) {
        self.schemaVersion = schemaVersion
        self.docks = docks
        self.globalHotkeys = globalHotkeys
        self.lastModified = lastModified
    }

    public static let empty = Library()
}
