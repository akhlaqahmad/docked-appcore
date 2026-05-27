import Foundation
import CryptoKit

#if canImport(IOKit)
import IOKit
#endif

public enum DeviceFingerprint {
    public static func compute(bundleID: String = Bundle.main.bundleIdentifier ?? "my.docked") -> String {
        let raw = platformUUID() + ":" + bundleID
        let digest = SHA256.hash(data: Data(raw.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private static func platformUUID() -> String {
        #if canImport(IOKit)
        let service = IOServiceMatching("IOPlatformExpertDevice")
        let platformExpert = IOServiceGetMatchingService(kIOMainPortDefault, service)
        defer { if platformExpert != 0 { IOObjectRelease(platformExpert) } }
        guard platformExpert != 0,
              let cf = IORegistryEntryCreateCFProperty(platformExpert, "IOPlatformUUID" as CFString, kCFAllocatorDefault, 0)
        else {
            return ProcessInfo.processInfo.globallyUniqueString
        }
        return (cf.takeRetainedValue() as? String) ?? ProcessInfo.processInfo.globallyUniqueString
        #else
        return ProcessInfo.processInfo.globallyUniqueString
        #endif
    }
}
