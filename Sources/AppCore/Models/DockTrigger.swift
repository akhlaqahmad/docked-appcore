import Foundation

public enum DockTrigger: Codable, Hashable, Sendable {
    case appActive(bundleID: String)
    case focusMode(identifier: String)
    case timeRange(startHour: Int, startMinute: Int, endHour: Int, endMinute: Int)
    case spaceIndex(Int)
    case manual

    public var humanDescription: String {
        switch self {
        case .appActive(let id): return "When \(id) is active"
        case .focusMode(let id): return "When Focus '\(id)' is on"
        case .timeRange(let sh, let sm, let eh, let em):
            return String(format: "From %02d:%02d to %02d:%02d", sh, sm, eh, em)
        case .spaceIndex(let idx): return "On Space #\(idx)"
        case .manual: return "Manual"
        }
    }
}
