import Foundation

public enum DockItem: Codable, Hashable, Identifiable, Sendable {
    case app(AppItem)
    case folder(FolderItem)
    case file(FileItem)
    case url(URLItem)
    case widget(WidgetItem)
    case separator(SeparatorItem)
    case spacer(SpacerItem)

    public var id: UUID {
        switch self {
        case .app(let v): return v.id
        case .folder(let v): return v.id
        case .file(let v): return v.id
        case .url(let v): return v.id
        case .widget(let v): return v.id
        case .separator(let v): return v.id
        case .spacer(let v): return v.id
        }
    }

    public var displayName: String {
        switch self {
        case .app(let v): return v.displayName ?? v.bundleID
        case .folder(let v): return v.displayName ?? v.path.lastPathComponent
        case .file(let v): return v.displayName ?? v.path.lastPathComponent
        case .url(let v): return v.displayName ?? v.url.host ?? v.url.absoluteString
        case .widget(let v): return v.kind.title
        case .separator: return "Separator"
        case .spacer: return "Spacer"
        }
    }
}

public struct AppItem: Codable, Hashable, Identifiable, Sendable {
    public let id: UUID
    public var bundleID: String
    public var appURL: URL
    public var displayName: String?
    public var iconOverridePath: String?

    public init(id: UUID = UUID(), bundleID: String, appURL: URL, displayName: String? = nil, iconOverridePath: String? = nil) {
        self.id = id
        self.bundleID = bundleID
        self.appURL = appURL
        self.displayName = displayName
        self.iconOverridePath = iconOverridePath
    }
}

public struct FolderItem: Codable, Hashable, Identifiable, Sendable {
    public enum Presentation: String, Codable, Sendable { case stack, grid, list }
    public let id: UUID
    public var path: URL
    public var displayName: String?
    public var presentation: Presentation

    public init(id: UUID = UUID(), path: URL, displayName: String? = nil, presentation: Presentation = .grid) {
        self.id = id
        self.path = path
        self.displayName = displayName
        self.presentation = presentation
    }
}

public struct FileItem: Codable, Hashable, Identifiable, Sendable {
    public let id: UUID
    public var path: URL
    public var displayName: String?

    public init(id: UUID = UUID(), path: URL, displayName: String? = nil) {
        self.id = id
        self.path = path
        self.displayName = displayName
    }
}

public struct URLItem: Codable, Hashable, Identifiable, Sendable {
    public let id: UUID
    public var url: URL
    public var displayName: String?
    public var iconOverridePath: String?

    public init(id: UUID = UUID(), url: URL, displayName: String? = nil, iconOverridePath: String? = nil) {
        self.id = id
        self.url = url
        self.displayName = displayName
        self.iconOverridePath = iconOverridePath
    }
}

public struct WidgetItem: Codable, Hashable, Identifiable, Sendable {
    public enum Kind: String, Codable, Sendable, CaseIterable {
        case clock, ipAddress, finder, trash, battery, calendar

        public var title: String {
            switch self {
            case .clock: return "Clock"
            case .ipAddress: return "IP Address"
            case .finder: return "Finder"
            case .trash: return "Trash"
            case .battery: return "Battery"
            case .calendar: return "Calendar"
            }
        }
    }

    public let id: UUID
    public var kind: Kind
    public var configuration: [String: String]

    public init(id: UUID = UUID(), kind: Kind, configuration: [String: String] = [:]) {
        self.id = id
        self.kind = kind
        self.configuration = configuration
    }
}

public struct SeparatorItem: Codable, Hashable, Identifiable, Sendable {
    public let id: UUID
    public init(id: UUID = UUID()) { self.id = id }
}

public struct SpacerItem: Codable, Hashable, Identifiable, Sendable {
    public let id: UUID
    public var size: CGFloat
    public init(id: UUID = UUID(), size: CGFloat = 12) {
        self.id = id
        self.size = size
    }
}
