import Foundation

public protocol LibraryStoreProtocol: AnyObject, Sendable {
    func load() throws -> Library
    func save(_ library: Library) throws
    var fileURL: URL { get }
}

public final class FileLibraryStore: LibraryStoreProtocol, @unchecked Sendable {
    public let fileURL: URL
    private let queue = DispatchQueue(label: "my.docked.library-store", qos: .userInitiated)
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(fileURL: URL = FileLibraryStore.defaultURL()) {
        self.fileURL = fileURL

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    public static func defaultURL() -> URL {
        let fm = FileManager.default
        let support = (try? fm.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)) ?? fm.temporaryDirectory
        let dir = support.appendingPathComponent("Docked", isDirectory: true)
        try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("library.json")
    }

    public func load() throws -> Library {
        try queue.sync {
            guard FileManager.default.fileExists(atPath: fileURL.path) else { return .empty }
            let data = try Data(contentsOf: fileURL)
            do {
                return try decoder.decode(Library.self, from: data)
            } catch {
                // Backup corrupt file, return empty rather than crash.
                let backup = fileURL.appendingPathExtension("backup-\(Int(Date.now.timeIntervalSince1970))")
                try? FileManager.default.moveItem(at: fileURL, to: backup)
                return .empty
            }
        }
    }

    public func save(_ library: Library) throws {
        try queue.sync {
            var lib = library
            lib.lastModified = .now
            let data = try encoder.encode(lib)
            let tmp = fileURL.appendingPathExtension("tmp")
            try data.write(to: tmp, options: .atomic)
            _ = try FileManager.default.replaceItemAt(fileURL, withItemAt: tmp)
        }
    }
}

public final class InMemoryLibraryStore: LibraryStoreProtocol, @unchecked Sendable {
    private let lock = NSLock()
    private var library: Library = .empty
    public let fileURL: URL = URL(fileURLWithPath: "/dev/null")

    public init(seed: Library = .empty) {
        self.library = seed
    }

    public func load() throws -> Library {
        lock.lock(); defer { lock.unlock() }
        return library
    }

    public func save(_ library: Library) throws {
        lock.lock(); defer { lock.unlock() }
        self.library = library
    }
}
