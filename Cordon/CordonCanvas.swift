import Foundation

/// State between the folded ledger and the canvas. Views read this. They do not fold marks.
struct CordonCanvasState: Equatable, Sendable {
    var phase: CordonPhase
    var isUnstaked: Bool
    var goalName: String
    var currencyCode: String
    var tray: Decimal
    var canopyTotal: Decimal
    var target: Decimal
    var progress: Decimal
    var wiresLit: [CanopyWire]
    var setCanopyEnabled: Bool
    var peelEnabled: Bool
    var vine: VineShape
    var openDrops: [DropMark]
    var setMarks: [SetMark]
    var hollowCount: Int
    var ripeCount: Int
    var statusMessage: String?

    static let unstaked = CordonCanvasState(
        phase: .bare,
        isUnstaked: true,
        goalName: "",
        currencyCode: "USD",
        tray: 0,
        canopyTotal: 0,
        target: 0,
        progress: 0,
        wiresLit: [],
        setCanopyEnabled: false,
        peelEnabled: false,
        vine: VineShape(lean: 0, forks: 1, twist: 0),
        openDrops: [],
        setMarks: [],
        hollowCount: 0,
        ripeCount: 0,
        statusMessage: nil
    )
}

enum CordonPresenter {
    static func present(ledger: CordonLedger, statusMessage: String? = nil) -> CordonCanvasState {
        guard let goal = ledger.activeGoal else {
            var empty = CordonCanvasState.unstaked
            empty.hollowCount = ledger.hollowMarks.count
            empty.ripeCount = ledger.ripeMarks.count
            empty.statusMessage = statusMessage
            return empty
        }
        let folded = ledger.fold(for: goal.id)
        let open = ledger.dropMarks.filter { $0.goalID == goal.id && !$0.settled }
        let committed = ledger.setMarks.filter { $0.goalID == goal.id }
        return CordonCanvasState(
            phase: folded.phase,
            isUnstaked: false,
            goalName: goal.name,
            currencyCode: goal.currencyCode,
            tray: folded.tray.amount,
            canopyTotal: folded.canopy.amount,
            target: goal.targetAmount,
            progress: folded.progress,
            wiresLit: folded.wiresLit,
            setCanopyEnabled: folded.phase == .trayed && !folded.tray.isEmpty,
            peelEnabled: !open.isEmpty,
            vine: VineShape.from(seed: goal.vineSeed),
            openDrops: open,
            setMarks: committed,
            hollowCount: ledger.hollowMarks.filter { $0.goalID == goal.id }.count,
            ripeCount: ledger.ripeMarks.filter { $0.goalID == goal.id }.count,
            statusMessage: statusMessage
        )
    }
}
