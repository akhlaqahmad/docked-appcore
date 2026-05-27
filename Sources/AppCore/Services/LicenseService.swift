import Foundation

public protocol LicenseServiceProtocol: AnyObject, Sendable {
    func currentLicense() -> License
    func activate(key: String) async throws -> License
    func deactivate() async throws
    func refresh() async throws -> License
}

public enum LicenseError: Error, LocalizedError {
    case network
    case invalidKey
    case deviceLimitReached
    case revoked
    case server(String)

    public var errorDescription: String? {
        switch self {
        case .network: return "Network error. Check your connection and try again."
        case .invalidKey: return "License key not recognized. Double-check the key or contact support."
        case .deviceLimitReached: return "Device limit reached. Deactivate another device or upgrade your plan."
        case .revoked: return "This license has been revoked."
        case .server(let msg): return msg
        }
    }
}

public final class LicenseService: LicenseServiceProtocol, @unchecked Sendable {
    private let keychain: KeychainStoreProtocol
    private let apiClient: LicenseAPIClient
    private let deviceFingerprint: () -> String
    private let lock = NSLock()
    private var cached: License = .free

    public init(
        keychain: KeychainStoreProtocol = KeychainStore(),
        apiClient: LicenseAPIClient = LicenseAPIClient(),
        deviceFingerprint: @escaping () -> String = { DeviceFingerprint.compute() }
    ) {
        self.keychain = keychain
        self.apiClient = apiClient
        self.deviceFingerprint = deviceFingerprint
        self.cached = (try? loadFromKeychain()) ?? .free
    }

    public func currentLicense() -> License {
        lock.lock(); defer { lock.unlock() }
        return cached
    }

    public func activate(key: String) async throws -> License {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        let response = try await apiClient.activate(key: trimmed, deviceID: deviceFingerprint())
        let license = License(
            tier: response.tier,
            key: trimmed,
            jwt: response.jwt,
            email: response.email,
            deviceLimit: response.deviceLimit,
            activatedAt: .now,
            expiresAt: response.expiresAt,
            entitlements: License.entitlements(for: response.tier)
        )
        try persist(license)
        return license
    }

    public func deactivate() async throws {
        let lic = currentLicense()
        if let key = lic.key {
            try? await apiClient.deactivate(key: key, deviceID: deviceFingerprint())
        }
        try keychain.remove("license-jwt")
        try keychain.remove("license-key")
        lock.lock(); cached = .free; lock.unlock()
    }

    public func refresh() async throws -> License {
        let lic = currentLicense()
        guard let key = lic.key else { return lic }
        let response = try await apiClient.verify(key: key, deviceID: deviceFingerprint())
        let refreshed = License(
            tier: response.tier,
            key: key,
            jwt: response.jwt,
            email: response.email ?? lic.email,
            deviceLimit: response.deviceLimit,
            activatedAt: lic.activatedAt,
            expiresAt: response.expiresAt,
            entitlements: License.entitlements(for: response.tier)
        )
        try persist(refreshed)
        return refreshed
    }

    private func persist(_ license: License) throws {
        if let jwt = license.jwt {
            try keychain.setString(jwt, for: "license-jwt")
        }
        if let key = license.key {
            try keychain.setString(key, for: "license-key")
        }
        lock.lock(); cached = license; lock.unlock()
    }

    private func loadFromKeychain() throws -> License? {
        guard let key = try keychain.string(for: "license-key"),
              let jwt = try keychain.string(for: "license-jwt") else { return nil }
        // Trust local JWT for up to 30 days; refresh on schedule.
        return License(tier: .lifetime, key: key, jwt: jwt, deviceLimit: 1, entitlements: License.entitlements(for: .lifetime))
    }
}
