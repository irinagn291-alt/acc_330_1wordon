import Foundation

/// Aggregate phase of one cordon. Folded from marks. Never stored as a source of truth.
enum CordonPhase: String, Codable, Equatable, Sendable {
    case bare
    case trayed
    case canopied
}

/// What a command did. Refusals still append an audit mark.
enum CordonCommandResult: Equatable, Sendable {
    case dropped
    case set(wires: [CanopyWire])
    case peeled
    case hollow
    case ripe
    case ignored
}

/// Snapshot of one goal after folding its marks.
struct CordonFold: Equatable, Sendable {
    var phase: CordonPhase
    var tray: TrayBalance
    var canopy: CanopyTotal
    var progress: Decimal
    var wiresLit: [CanopyWire]

    /// An unstaked cordon is bare. Tray cash is not height.
    static let bare = CordonFold(
        phase: .bare,
        tray: .zero,
        canopy: .zero,
        progress: 0,
        wiresLit: []
    )
}

/// The cordon is a fold over set marks and the open tray.
/// Drop appends a DropMark and folds bare into trayed.
/// Set appends a SetMark, moves the tray into canopy, and folds trayed to canopied or bare.
/// Set on bare or an empty tray appends a HollowMark.
/// Drop on a ripe cordon appends a RipeMark.
/// Peel removes only the latest open DropMark.
struct CordonLedger: Equatable, Sendable {
    var goals: [CordonGoal]
    var setMarks: [SetMark]
    var dropMarks: [DropMark]
    var hollowMarks: [HollowMark]
    var ripeMarks: [RipeMark]
    var activeGoalID: UUID?
    var onboardingComplete: Bool
    var quickDropAmounts: [Decimal]

    static let empty = CordonLedger(
        goals: [],
        setMarks: [],
        dropMarks: [],
        hollowMarks: [],
        ripeMarks: [],
        activeGoalID: nil,
        onboardingComplete: false,
        quickDropAmounts: [5, 10, 20, 50]
    )

    func goal(_ id: UUID) -> CordonGoal? {
        goals.first { $0.id == id }
    }

    var activeGoal: CordonGoal? {
        guard let activeGoalID else { return nil }
        return goal(activeGoalID)
    }

    func fold(for goalID: UUID?) -> CordonFold {
        guard let goalID, let goal = goal(goalID) else { return .bare }
        let canopyAmount = setMarks
            .filter { $0.goalID == goalID }
            .reduce(Decimal(0)) { $0 + $1.amount }
        let trayAmount = dropMarks
            .filter { $0.goalID == goalID && !$0.settled }
            .reduce(Decimal(0)) { $0 + $1.amount }
        let progress = CanopyTotal.progress(canopy: canopyAmount, target: goal.targetAmount)
        let ripe = goal.targetAmount > 0 && canopyAmount >= goal.targetAmount
        let phase: CordonPhase
        if ripe {
            phase = .canopied
        } else if trayAmount > 0 {
            phase = .trayed
        } else {
            phase = .bare
        }
        let lit = CanopyWire.allCases.filter { progress >= $0.threshold }
        return CordonFold(
            phase: phase,
            tray: TrayBalance(amount: trayAmount),
            canopy: CanopyTotal(amount: canopyAmount),
            progress: progress,
            wiresLit: lit
        )
    }

    var activeFold: CordonFold { fold(for: activeGoalID) }

    mutating func plant(_ goal: CordonGoal, makeActive: Bool = true) {
        goals.append(goal)
        if makeActive || activeGoalID == nil {
            activeGoalID = goal.id
        }
    }

    mutating func activate(_ id: UUID) {
        guard goal(id) != nil else { return }
        activeGoalID = id
    }

    /// Drop a hand amount into the tray. Canopy height stays put.
    @discardableResult
    mutating func drop(amount: Decimal, dayKey: Int, goalID: UUID? = nil) -> CordonCommandResult {
        guard amount > 0 else { return .ignored }
        guard let id = goalID ?? activeGoalID, goal(id) != nil else { return .ignored }
        let current = fold(for: id)
        if current.phase == .canopied {
            ripeMarks.append(RipeMark(goalID: id, amount: amount, dayKey: dayKey))
            return .ripe
        }
        dropMarks.append(DropMark(goalID: id, amount: amount, dayKey: dayKey))
        return .dropped
    }

    /// Home verb. Commits the whole tray, or writes a hollow mark when refused.
    @discardableResult
    mutating func setCanopy(dayKey: Int, goalID: UUID? = nil) -> CordonCommandResult {
        guard let id = goalID ?? activeGoalID, let goal = goal(id) else {
            hollowMarks.append(HollowMark(goalID: nil, dayKey: dayKey))
            return .hollow
        }
        let current = fold(for: id)
        if current.phase == .bare || current.tray.isEmpty {
            hollowMarks.append(HollowMark(goalID: id, dayKey: dayKey))
            return .hollow
        }
        let before = current.progress
        let nextCanopy = current.canopy.amount + current.tray.amount
        let after = CanopyTotal.progress(canopy: nextCanopy, target: goal.targetAmount)
        let wires = CanopyWire.crossed(before: before, after: after)
        setMarks.append(
            SetMark(
                goalID: id,
                amount: current.tray.amount,
                dayKey: dayKey,
                canopyTotalAfter: nextCanopy,
                wiresCrossed: wires
            )
        )
        for index in dropMarks.indices where dropMarks[index].goalID == id && !dropMarks[index].settled {
            dropMarks[index].settled = true
        }
        return .set(wires: wires)
    }

    /// Peel the latest open drop. Committed canopy never walks backward.
    @discardableResult
    mutating func peelLastDrop(goalID: UUID? = nil) -> CordonCommandResult {
        guard let id = goalID ?? activeGoalID else { return .ignored }
        guard let index = dropMarks.lastIndex(where: { $0.goalID == id && !$0.settled }) else {
            return .ignored
        }
        dropMarks.remove(at: index)
        return .peeled
    }
}
