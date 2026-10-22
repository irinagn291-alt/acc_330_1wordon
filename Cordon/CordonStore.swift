import Foundation

/// Seam between the fold and the canvas. The view never reads the file.
@MainActor
@Observable
final class CordonStore {
    private(set) var ledger: CordonLedger
    private(set) var canvas: CordonCanvasState
    private(set) var loadStatus: CordonLoadStatus
    private let disk: CordonDisk
    private let allowsDemoSeed: Bool
    private var saveTask: Task<Void, Never>?
    private var seededThisLaunch = false

    init(
        fileURL: URL,
        defaultsSuite: String? = nil,
        ledger: CordonLedger = .empty,
        allowsDemoSeed: Bool = true
    ) {
        self.ledger = ledger
        self.canvas = CordonPresenter.present(ledger: ledger)
        self.loadStatus = .ready
        self.disk = CordonDisk(fileURL: fileURL, defaultsSuite: defaultsSuite)
        self.allowsDemoSeed = allowsDemoSeed
    }

    convenience init() {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let url = base.appendingPathComponent("1Wordon", isDirectory: true)
            .appendingPathComponent("cordon-archive.json")
        self.init(fileURL: url)
    }

    func bootstrap() async {
        let loaded = await disk.load()
        ledger = loaded.archive.ledger
        loadStatus = loaded.status
        await applySeedIfNeeded()
        var notice: String?
        switch loadStatus {
        case .startedEmpty(let text):
            notice = text
        case .recoveredFromBackup:
            notice = "Restored the last good garden file."
        case .ready:
            notice = nil
        }
        canvas = CordonPresenter.present(ledger: ledger, statusMessage: notice)
        if seededThisLaunch {
            await flush()
        }
    }

    func drop(amount: Decimal, dayKey: Int) {
        let result = ledger.drop(amount: amount, dayKey: dayKey)
        publish(result)
    }

    func setCanopy(dayKey: Int) {
        let result = ledger.setCanopy(dayKey: dayKey)
        publish(result)
    }

    func peelLastDrop() {
        let result = ledger.peelLastDrop()
        publish(result)
    }

    func plant(_ goal: CordonGoal) {
        ledger.plant(goal)
        publish(.ignored)
    }

    func activate(_ id: UUID) {
        ledger.activate(id)
        publish(.ignored)
    }

    func completeOnboarding() {
        ledger.onboardingComplete = true
        publish(.ignored)
    }

    /// Settings can show the intro again. The fold is unchanged.
    func reopenOnboarding() {
        ledger.onboardingComplete = false
        publish(.ignored)
    }

    /// Quick-drop chips. Empty input restores the built-in denominations.
    func replaceQuickDrops(_ amounts: [Decimal]) {
        let clean = amounts.filter { $0 > 0 }
        ledger.quickDropAmounts = clean.isEmpty ? CordonLedger.empty.quickDropAmounts : clean
        publish(.ignored)
    }

    func resetAllData() async {
        saveTask?.cancel()
        saveTask = nil
        ledger = .empty
        loadStatus = .ready
        canvas = CordonPresenter.present(ledger: ledger)
        do {
            try await disk.destroy()
        } catch {
            canvas = CordonPresenter.present(
                ledger: ledger,
                statusMessage: "Reset could not clear the garden file. Try again."
            )
            return
        }
        await flush()
    }

    func flush() async {
        saveTask?.cancel()
        saveTask = nil
        let archive = CordonArchive(ledger: ledger)
        do {
            try await disk.write(archive)
        } catch {
            canvas = CordonPresenter.present(
                ledger: ledger,
                statusMessage: "The garden could not be saved. This session is still on screen."
            )
        }
    }

    func exportCSV(to directory: URL) async throws -> URL {
        let snapshot = ledger
        return try await disk.exportCSV(snapshot, directory: directory)
    }

    private func publish(_ result: CordonCommandResult) {
        let note: String?
        switch result {
        case .hollow:
            note = "Tray is empty. Drop cash, then set the canopy."
        case .ripe:
            note = "This goal is ripe. Plant another goal to drop again."
        case .ignored:
            note = canvas.statusMessage
        case .dropped, .set, .peeled:
            note = nil
        }
        canvas = CordonPresenter.present(ledger: ledger, statusMessage: note)
        scheduleSave()
    }

    private func scheduleSave() {
        saveTask?.cancel()
        let archive = CordonArchive(ledger: ledger)
        saveTask = Task { [disk] in
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            do {
                try await disk.write(archive)
            } catch {
                canvas = CordonPresenter.present(
                    ledger: ledger,
                    statusMessage: "The garden could not be saved. This session is still on screen."
                )
            }
        }
    }

    private func applySeedIfNeeded() async {
        #if targetEnvironment(simulator)
        guard allowsDemoSeed else { return }
        guard ledger.goals.isEmpty else { return }
        guard await disk.isDemoSeeded() == false else { return }
        let seeded = CordonDemo.archive()
        ledger = seeded.ledger
        await disk.setDemoSeeded()
        seededThisLaunch = true
        loadStatus = .ready
        #endif
    }
}
