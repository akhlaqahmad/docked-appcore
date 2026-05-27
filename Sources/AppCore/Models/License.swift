import Foundation

public struct License: Codable, Hashable, Sendable {
    public enum Tier: String, Codable, Sendable {
        case free, oneYear, lifetime, family, teams
    }

    public var tier: Tier
    public var key: String?
    public var jwt: String?
    public var email: String?
    public var deviceLimit: Int
    public var activatedAt: Date?
    public var expiresAt: Date?
    public var entitlements: Set<Entitlement>

    public init(
        tier: Tier = .free,
        key: String? = nil,
        jwt: String? = nil,
        email: String? = nil,
        deviceLimit: Int = 1,
        activatedAt: Date? = nil,
        expiresAt: Date? = nil,
        entitlements: Set<Entitlement> = License.entitlements(for: .free)
    ) {
        self.tier = tier
        self.key = key
        self.jwt = jwt
        self.email = email
        self.deviceLimit = deviceLimit
        self.activatedAt = activatedAt
        self.expiresAt = expiresAt
        self.entitlements = entitlements
    }

    public static let free = License()

    public var isPro: Bool {
        tier != .free && entitlements.contains(.unlimitedDocks)
    }

    public static func entitlements(for tier: Tier) -> Set<Entitlement> {
        switch tier {
        case .free:
            return [.basicAppearance]
        case .oneYear, .lifetime, .family:
            return [.basicAppearance, .unlimitedDocks, .unlimitedItems, .allWidgets, .triggers, .extraBar, .perItemOverrides]
        case .teams:
            return [.basicAppearance, .unlimitedDocks, .unlimitedItems, .allWidgets, .triggers, .extraBar, .perItemOverrides, .teamManagement]
        }
    }
}

public enum Entitlement: String, Codable, Sendable {
    case basicAppearance
    case unlimitedDocks
    case unlimitedItems
    case allWidgets
    case triggers
    case extraBar
    case perItemOverrides
    case cloudSync          // separate add-on, not bundled
    case themeMarketplace
    case teamManagement
}

public struct FreeTierLimits {
    public static let maxDocks = 1
    public static let maxItemsPerDock = 8
}
