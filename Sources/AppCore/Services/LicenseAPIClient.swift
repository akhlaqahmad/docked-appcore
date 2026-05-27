import Foundation

public struct LicenseAPIResponse: Codable, Sendable {
    public let tier: License.Tier
    public let jwt: String
    public let email: String?
    public let deviceLimit: Int
    public let expiresAt: Date?
}

public final class LicenseAPIClient: Sendable {
    public let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder

    public init(
        baseURL: URL = URL(string: "https://api.docked.my")!,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        self.decoder = d
    }

    public func activate(key: String, deviceID: String) async throws -> LicenseAPIResponse {
        try await request("/v1/license/activate", payload: ["key": key, "deviceID": deviceID])
    }

    public func deactivate(key: String, deviceID: String) async throws {
        let _: EmptyResponse = try await request("/v1/license/deactivate", payload: ["key": key, "deviceID": deviceID])
    }

    public func verify(key: String, deviceID: String) async throws -> LicenseAPIResponse {
        try await request("/v1/license/verify", payload: ["key": key, "deviceID": deviceID])
    }

    private func request<T: Decodable>(_ path: String, payload: [String: String]) async throws -> T {
        var req = URLRequest(url: baseURL.appendingPathComponent(path))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(payload)
        req.timeoutInterval = 15

        let (data, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse else { throw LicenseError.network }
        switch http.statusCode {
        case 200..<300:
            if T.self == EmptyResponse.self { return EmptyResponse() as! T }
            return try decoder.decode(T.self, from: data)
        case 401, 403: throw LicenseError.revoked
        case 404: throw LicenseError.invalidKey
        case 409: throw LicenseError.deviceLimitReached
        case 500..<600:
            let message = String(data: data, encoding: .utf8) ?? "Server error"
            throw LicenseError.server(message)
        default:
            throw LicenseError.network
        }
    }
}

private struct EmptyResponse: Decodable {}
