import XCTest
@testable import Cordon

@MainActor
final class CordonTests: XCTestCase {
    func testProgressIsCanopyOverTargetAndIgnoresTray() {
        var ledger = CordonLedger.empty
        let goal = makeGoal(target: 100)
        ledger.plant(goal)
        XCTAssertEqual(ledger.drop(amount: 40, dayKey: 20261001), .dropped)
        let folded = ledger.activeFold
        XCTAssertEqual(folded.phase, .trayed)
        XCTAssertEqual(folded.tray.amount, 40)
        XCTAssertEqual(folded.canopy.amount, 0)
        XCTAssertEqual(folded.progress, 0)
        XCTAssertEqual(ledger.setCanopy(dayKey: 20261002), .set(wires: [.quarter]))
        let after = ledger.activeFold
        XCTAssertEqual(after.canopy.amount, 40)
        XCTAssertEqual(after.tray.amount, 0)
        XCTAssertEqual(after.progress, Decimal(string: "0.4"))
        XCTAssertEqual(after.phase, .bare)
        XCTAssertEqual(after.wiresLit, [.quarter])
    }

    func testSetOnBareWritesHollowAndLeavesCanopy() {
        var ledger = CordonLedger.empty
        ledger.plant(makeGoal(target: 80))
        let before = ledger.activeFold.canopy.amount
        XCTAssertEqual(ledger.activeFold.phase, .bare)
        XCTAssertEqual(ledger.setCanopy(dayKey: 20261003), .hollow)
        XCTAssertEqual(ledger.hollowMarks.count, 1)
        XCTAssertEqual(ledger.setMarks.count, 0)
        XCTAssertEqual(ledger.activeFold.canopy.amount, before)
        XCTAssertEqual(ledger.activeFold.phase, .bare)
    }

    func testEmptyTrayAfterPeelRefusesSet() {
        var ledger = CordonLedger.empty
        ledger.plant(makeGoal(target: 50))
        XCTAssertEqual(ledger.drop(amount: 10, dayKey: 20261004), .dropped)
        XCTAssertEqual(ledger.peelLastDrop(), .peeled)
        XCTAssertEqual(ledger.activeFold.phase, .bare)
        XCTAssertEqual(ledger.setCanopy(dayKey: 20261004), .hollow)
        XCTAssertTrue(ledger.dropMarks.isEmpty)
    }

    func testDropThenSetReachesCanopiedAndDropOnRipeIsRefused() {
        var ledger = CordonLedger.empty
        ledger.plant(makeGoal(target: 30))
        XCTAssertEqual(ledger.drop(amount: 12, dayKey: 20261005), .dropped)
        XCTAssertEqual(ledger.drop(amount: 18, dayKey: 20261005), .dropped)
        let canopyBeforeSet = ledger.activeFold.canopy.amount
        XCTAssertEqual(canopyBeforeSet, 0)
        let result = ledger.setCanopy(dayKey: 20261006)
        XCTAssertEqual(result, .set(wires: [.quarter, .half, .threeQuarter, .ripe]))
        XCTAssertEqual(ledger.activeFold.phase, .canopied)
        XCTAssertEqual(ledger.activeFold.canopy.amount, 30)
        XCTAssertEqual(ledger.activeFold.progress, 1)
        XCTAssertEqual(ledger.drop(amount: 5, dayKey: 20261007), .ripe)
        XCTAssertEqual(ledger.ripeMarks.count, 1)
        XCTAssertEqual(ledger.activeFold.canopy.amount, 30)
        XCTAssertEqual(ledger.activeFold.tray.amount, 0)
    }

    func testInvalidDropIsIgnored() {
        var ledger = CordonLedger.empty
        ledger.plant(makeGoal(target: 20))
        XCTAssertEqual(ledger.drop(amount: 0, dayKey: 20261001), .ignored)
        XCTAssertEqual(ledger.drop(amount: -4, dayKey: 20261001), .ignored)
        XCTAssertTrue(ledger.dropMarks.isEmpty)
        XCTAssertEqual(ledger.activeFold.phase, .bare)
    }

    func testPeelRemovesOnlyTheLatestOpenDrop() {
        var ledger = CordonLedger.empty
        ledger.plant(makeGoal(target: 200))
        _ = ledger.drop(amount: 10, dayKey: 20261001)
        _ = ledger.setCanopy(dayKey: 20261001)
        _ = ledger.drop(amount: 7, dayKey: 20261002)
        _ = ledger.drop(amount: 3, dayKey: 20261003)
        let canopy = ledger.activeFold.canopy.amount
        XCTAssertEqual(ledger.peelLastDrop(), .peeled)
        XCTAssertEqual(ledger.activeFold.tray.amount, 7)
        XCTAssertEqual(ledger.activeFold.canopy.amount, canopy)
        XCTAssertEqual(ledger.activeFold.phase, .trayed)
    }

    func testUnstakedCordonIsBare() {
        var ledger = CordonLedger.empty
        XCTAssertNil(ledger.activeGoalID)
        XCTAssertEqual(ledger.activeFold, .bare)
        XCTAssertEqual(ledger.setCanopy(dayKey: 20261001), .hollow)
    }

    func testFoldIsDeterminedByMarks() {
        var ledger = CordonLedger.empty
        let goal = makeGoal(target: 100, seed: 99)
        ledger.plant(goal)
        _ = ledger.drop(amount: 25, dayKey: 20261001)
        let first = ledger.fold(for: goal.id)
        let again = ledger.fold(for: goal.id)
        XCTAssertEqual(first, again)
        XCTAssertEqual(first.phase, .trayed)
        XCTAssertEqual(VineShape.from(seed: 99), VineShape.from(seed: 99))
        XCTAssertNotEqual(VineShape.from(seed: 99), VineShape.from(seed: 100))
        let canvas = CordonPresenter.present(ledger: ledger)
        XCTAssertTrue(canvas.setCanopyEnabled)
        XCTAssertEqual(canvas.canopyTotal, 0)
        XCTAssertEqual(canvas.tray, 25)
    }

    func testMilestoneWiresAtQuartiles() {
        XCTAssertEqual(CanopyWire.crossed(before: 0, after: Decimal(string: "0.24") ?? 0), [])
        XCTAssertEqual(CanopyWire.crossed(before: 0, after: Decimal(string: "0.25") ?? 0), [.quarter])
        XCTAssertEqual(
            CanopyWire.crossed(before: Decimal(string: "0.2") ?? 0, after: Decimal(string: "0.8") ?? 0),
            [.quarter, .half, .threeQuarter]
        )
        XCTAssertEqual(CanopyTotal.progress(canopy: 50, target: 200), Decimal(string: "0.25"))
        XCTAssertEqual(CanopyTotal.progress(canopy: 10, target: 0), 0)
    }

    func testArchiveRoundTripAndBackup() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("cordon-tests-\(UUID().uuidString)", isDirectory: true)
        let fileURL = directory.appendingPathComponent("cordon-archive.json")
        let suite = "cordon.tests.\(UUID().uuidString)"
        let store = CordonStore(fileURL: fileURL, defaultsSuite: suite, allowsDemoSeed: false)
        await store.bootstrap()
        store.plant(makeGoal(target: 90, name: "Ferry"))
        store.drop(amount: 20, dayKey: 20261011)
        store.drop(amount: 15, dayKey: 20261012)
        store.setCanopy(dayKey: 20261012)
        await store.flush()

        let reloaded = CordonStore(fileURL: fileURL, defaultsSuite: suite, allowsDemoSeed: false)
        await reloaded.bootstrap()
        XCTAssertEqual(reloaded.ledger.goals.count, 1)
        XCTAssertEqual(reloaded.ledger.goals[0].name, "Ferry")
        XCTAssertEqual(reloaded.canvas.canopyTotal, 35)
        XCTAssertEqual(reloaded.canvas.phase, .bare)
        XCTAssertEqual(reloaded.canvas.tray, 0)
        let defaults = UserDefaults(suiteName: suite)
        XCTAssertNotNil(defaults?.data(forKey: CordonArchive.defaultsKey))

        let backup = fileURL.appendingPathExtension("backup")
        let good = try Data(contentsOf: fileURL)
        try good.write(to: backup, options: .atomic)
        try Data("not-json".utf8).write(to: fileURL, options: .atomic)
        defaults?.removeObject(forKey: CordonArchive.defaultsKey)
        let recovered = CordonStore(fileURL: fileURL, defaultsSuite: suite, allowsDemoSeed: false)
        await recovered.bootstrap()
        XCTAssertEqual(recovered.loadStatus, .recoveredFromBackup)
        XCTAssertEqual(recovered.canvas.canopyTotal, 35)

        await store.resetAllData()
        let cleared = CordonStore(fileURL: fileURL, defaultsSuite: suite, allowsDemoSeed: false)
        await cleared.bootstrap()
        XCTAssertTrue(cleared.ledger.goals.isEmpty)
        try? FileManager.default.removeItem(at: directory)
    }

    func testReviewLaunchParsesCoverKeys() {
        XCTAssertNil(ReviewLaunch.screen(from: ["Cordon"]))
        XCTAssertEqual(ReviewLaunch.screen(from: ["Cordon", "-ReviewScreen", "today"]), "today")
        XCTAssertEqual(ReviewLaunch.screen(from: ["Cordon", "-ReviewScreen", "log"]), "log")
        XCTAssertEqual(ReviewLaunch.screen(from: ["Cordon", "-ReviewScreen", "goals"]), "goals")
        XCTAssertEqual(ReviewLaunch.screen(from: ["Cordon", "-ReviewScreen", "settings"]), "settings")
        XCTAssertNil(ReviewLaunch.screen(from: ["Cordon", "-ReviewScreen"]))
    }

    func testSchemaRejectsUnknownVersion() {
        let payload = #"{"schemaVersion":9,"goals":[]}"#
        XCTAssertThrowsError(try CordonArchive.decodeData(Data(payload.utf8)))
    }

    private func makeGoal(
        target: Decimal,
        name: String = "Week",
        seed: UInt64 = 7
    ) -> CordonGoal {
        CordonGoal(
            name: name,
            targetAmount: target,
            vineSeed: seed,
            plantedDayKey: 20261001
        )
    }
}
