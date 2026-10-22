import Foundation

/// File projection of the in-memory archive. Writes are atomic and off the main actor.
actor CordonDisk {
    let fileURL: URL
    private let defaults: UserDefaults

    init(fileURL: URL, defaultsSuite: String?) {
        self.fileURL = fileURL
        if let defaultsSuite, let suite = UserDefaults(suiteName: defaultsSuite) {
            self.defaults = suite
        } else {
            self.defaults = .standard
        }
    }

    func isDemoSeeded() -> Bool {
        defaults.object(forKey: CordonArchive.demoKey) != nil
    }

    func setDemoSeeded() {
        defaults.set(true, forKey: CordonArchive.demoKey)
    }

    func load() -> CordonLoad {
        let backupURL = fileURL.appendingPathExtension("backup")
        let fileExists = FileManager.default.fileExists(atPath: fileURL.path)
        if fileExists, let data = try? Data(contentsOf: fileURL), let archive = try? CordonArchive.decodeData(data) {
            return CordonLoad(archive: archive, status: .ready)
        }
        if fileExists {
            preserveCorruptFile(backupURL: backupURL)
        }
        if let data = try? Data(contentsOf: backupURL), let archive = try? CordonArchive.decodeData(data) {
            return CordonLoad(archive: archive, status: .recoveredFromBackup)
        }
        if let blob = defaults.data(forKey: CordonArchive.defaultsKey),
           let archive = try? CordonArchive.decodeData(blob) {
            return CordonLoad(archive: archive, status: .recoveredFromBackup)
        }
        if !fileExists {
            return CordonLoad(archive: CordonArchive(ledger: .empty), status: .ready)
        }
        return CordonLoad(
            archive: CordonArchive(ledger: .empty),
            status: .startedEmpty("The garden file could not be read. Starting from an empty cordon.")
        )
    }

    func write(_ archive: CordonArchive) throws {
        let data = try CordonArchive.encodeData(archive)
        let directory = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let temporary = directory.appendingPathComponent("cordon-\(UUID().uuidString).tmp")
        try data.write(to: temporary, options: .atomic)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            let backupURL = fileURL.appendingPathExtension("backup")
            if FileManager.default.fileExists(atPath: backupURL.path) {
                try FileManager.default.removeItem(at: backupURL)
            }
            try FileManager.default.copyItem(at: fileURL, to: backupURL)
            _ = try FileManager.default.replaceItemAt(fileURL, withItemAt: temporary)
        } else {
            try FileManager.default.moveItem(at: temporary, to: fileURL)
        }
        defaults.set(data, forKey: CordonArchive.defaultsKey)
    }

    func exportCSV(_ ledger: CordonLedger, directory: URL) throws -> URL {
        try CSVExporter.writeFile(ledger: ledger, directory: directory)
    }

    func destroy() throws {
        let backupURL = fileURL.appendingPathExtension("backup")
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
        if FileManager.default.fileExists(atPath: backupURL.path) {
            try FileManager.default.removeItem(at: backupURL)
        }
        defaults.removeObject(forKey: CordonArchive.defaultsKey)
        defaults.removeObject(forKey: CordonArchive.demoKey)
    }

    private func preserveCorruptFile(backupURL: URL) {
        guard !FileManager.default.fileExists(atPath: backupURL.path) else { return }
        do {
            try FileManager.default.copyItem(at: fileURL, to: backupURL)
        } catch {
            return
        }
    }
}
