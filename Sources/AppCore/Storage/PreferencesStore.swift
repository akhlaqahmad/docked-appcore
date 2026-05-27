import Foundation

public protocol PreferencesStoreProtocol: Sendable {
    func bool(for key: String, default defaultValue: Bool) -> Bool
    func setBool(_ value: Bool, for key: String)
    func string(for key: String) -> String?
    func setString(_ value: String?, for key: String)
}

public final class UserDefaultsPreferencesStore: PreferencesStoreProtocol, @unchecked Sendable {
    private let defaults: UserDefaults

    public init(suiteName: String = "my.docked") {
        self.defaults = UserDefaults(suiteName: suiteName) ?? .standard
    }

    public func bool(for key: String, default defaultValue: Bool) -> Bool {
        if defaults.object(forKey: key) == nil { return defaultValue }
        return defaults.bool(forKey: key)
    }

    public func setBool(_ value: Bool, for key: String) {
        defaults.set(value, forKey: key)
    }

    public func string(for key: String) -> String? {
        defaults.string(forKey: key)
    }

    public func setString(_ value: String?, for key: String) {
        defaults.set(value, forKey: key)
    }
}

public enum PreferenceKeys {
    public static let onboardingComplete = "onboarding.complete.v1"
    public static let lastActiveDockID = "lastActiveDockID"
    public static let launchAtLogin = "launchAtLogin"
    public static let analyticsOptIn = "analyticsOptIn"
}
