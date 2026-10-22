import SwiftUI

/// Goal switcher. Distinct from the plant form.
struct GoalsBoardView: View {
    var showsClose: Bool = false
    var onClose: () -> Void = {}
    var onPlant: () -> Void = {}

    @Environment(CordonStore.self) private var store

    var body: some View {
        CoverPageCard(title: CanopyCopy.goals, showsClose: showsClose, onClose: onClose) {
            Group {
                if store.ledger.goals.isEmpty {
                    EmptyStateCard(
                        imageName: "cdn_EmptyHome",
                        title: CanopyCopy.emptyTitle,
                        line: CanopyCopy.emptyBody,
                        actionTitle: CanopyCopy.plantFirst,
                        action: onPlant
                    )
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: CanopyMetrics.steps(2)) {
                            ForEach(store.ledger.goals) { goal in
                                Button {
                                    store.activate(goal.id)
                                } label: {
                                    LedgerLineRow(
                                        title: goal.name,
                                        detail: goal.id == store.ledger.activeGoalID ? CanopyCopy.active : CanopyCopy.switchGoal,
                                        amount: CanopyFormat.money(goal.targetAmount, code: goal.currencyCode),
                                        accentAmount: goal.id == store.ledger.activeGoalID
                                    )
                                }
                                .buttonStyle(CanopyRowStyle())
                                .frame(minHeight: CanopyMetrics.hit)
                                .padding(.horizontal, CanopyMetrics.steps(2))
                                .background(
                                    CanopyColor.surface,
                                    in: RoundedRectangle(cornerRadius: CanopyRadius.card, style: .continuous)
                                )
                                .overlay {
                                    RoundedRectangle(cornerRadius: CanopyRadius.card, style: .continuous)
                                        .stroke(
                                            goal.id == store.ledger.activeGoalID ? CanopyColor.accent : CanopyColor.hairline,
                                            lineWidth: CanopyMetrics.hairline
                                        )
                                }
                            }
                            Button(action: onPlant) {
                                Text(CanopyCopy.plantGoal)
                            }
                            .buttonStyle(CanopyButtonStyle(kind: .primary))
                        }
                        .padding(CanopyMetrics.steps(3))
                    }
                }
            }
        }
    }
}

struct SetMarkView: View {
    var showsClose: Bool = false
    var onClose: () -> Void = {}
    @Environment(CordonStore.self) private var store

    var body: some View {
        CoverPageCard(title: CanopyCopy.commits, showsClose: showsClose, onClose: onClose) {
            ScrollView {
                VStack(alignment: .leading, spacing: CanopyMetrics.steps(2)) {
                    Text(CanopyCopy.waitingToCommit)
                        .canopyFont(.label, bold: true)
                        .foregroundStyle(CanopyColor.muted)
                    Text(CanopyFormat.money(store.canvas.tray, code: store.canvas.currencyCode))
                        .canopyFont(.hero, bold: true)
                        .foregroundStyle(CanopyColor.accent)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Text(CanopyCopy.stillInTray(store.canvas.goalName))
                        .canopyFont(.body)
                        .foregroundStyle(CanopyColor.ink)
                    Button(action: commitWaiting) {
                        Text(store.canvas.setCanopyEnabled
                             ? CanopyCopy.commitAmount(
                                CanopyFormat.money(store.canvas.tray, code: store.canvas.currencyCode),
                                goal: store.canvas.goalName
                             )
                             : CanopyCopy.addDrop)
                            .frame(maxWidth: .infinity, minHeight: CanopyMetrics.hit)
                            .contentShape(Capsule())
                    }
                    .buttonStyle(CanopyButtonStyle(kind: .primary))
                    Text(CanopyCopy.pastCommits)
                        .canopyFont(.title, bold: true)
                        .foregroundStyle(CanopyColor.ink)
                    ForEach(store.ledger.setMarks) { mark in
                        LedgerLineRow(
                            title: CanopyFormat.dayKey(mark.dayKey),
                            detail: CanopyCopy.commitWord,
                            amount: CanopyFormat.money(mark.amount, code: code(for: mark.goalID))
                        )
                    }
                }
                .padding(CanopyMetrics.steps(3))
            }
        }
    }

    private func commitWaiting() {
        if store.canvas.setCanopyEnabled {
            store.setCanopy(dayKey: DayKey.make(from: Date()))
        } else {
            let amount = store.ledger.quickDropAmounts.first ?? 1
            store.drop(amount: amount, dayKey: DayKey.make(from: Date()))
        }
    }

    private func code(for goalID: UUID) -> String {
        store.ledger.goal(goalID)?.currencyCode ?? store.canvas.currencyCode
    }
}

struct TrayView: View {
    var showsClose: Bool = false
    var onClose: () -> Void = {}
    @Environment(CordonStore.self) private var store

    var body: some View {
        CoverPageCard(title: CanopyCopy.waiting, showsClose: showsClose, onClose: onClose) {
            let open = store.ledger.dropMarks.filter { !$0.settled }
            ScrollView {
                VStack(alignment: .leading, spacing: CanopyMetrics.steps(2)) {
                    Text(CanopyCopy.inTheTray)
                        .canopyFont(.label, bold: true)
                        .foregroundStyle(CanopyColor.muted)
                    Text(CanopyFormat.money(store.canvas.tray, code: store.canvas.currencyCode))
                        .canopyFont(.hero, bold: true)
                        .foregroundStyle(CanopyColor.accent)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Text(CanopyCopy.dropsNotSaved(store.canvas.goalName))
                        .canopyFont(.body)
                        .foregroundStyle(CanopyColor.ink)
                    Button(action: commitTray) {
                        Text(CanopyCopy.commitToGoal(CanopyFormat.money(store.canvas.tray, code: store.canvas.currencyCode)))
                            .frame(maxWidth: .infinity, minHeight: CanopyMetrics.hit)
                            .contentShape(Capsule())
                    }
                    .buttonStyle(CanopyButtonStyle(kind: .primary))
                    .disabled(!store.canvas.setCanopyEnabled)
                    Button(action: addDrop) {
                        Text(CanopyCopy.addDrop)
                            .frame(maxWidth: .infinity, minHeight: CanopyMetrics.hit)
                            .contentShape(Capsule())
                    }
                    .buttonStyle(CanopyButtonStyle(kind: .secondary))
                    Button(action: { store.peelLastDrop() }) {
                        Text(CanopyCopy.peelLast)
                            .frame(maxWidth: .infinity, minHeight: CanopyMetrics.hit)
                            .contentShape(Capsule())
                    }
                    .buttonStyle(CanopyButtonStyle(kind: .secondary))
                    .disabled(open.isEmpty)
                    ForEach(open) { mark in
                        LedgerLineRow(
                            title: CanopyCopy.drop,
                            detail: CanopyFormat.dayKey(mark.dayKey),
                            amount: CanopyFormat.money(mark.amount, code: code(for: mark.goalID))
                        )
                        .padding(CanopyMetrics.steps(2))
                        .background(CanopyColor.surface, in: RoundedRectangle(cornerRadius: CanopyRadius.card, style: .continuous))
                    }
                }
                .padding(CanopyMetrics.steps(3))
            }
        }
    }

    private func addDrop() {
        let amount = store.ledger.quickDropAmounts.first ?? 1
        store.drop(amount: amount, dayKey: DayKey.make(from: Date()))
    }

    private func commitTray() {
        guard store.canvas.setCanopyEnabled else { return }
        store.setCanopy(dayKey: DayKey.make(from: Date()))
    }

    private func code(for goalID: UUID) -> String {
        store.ledger.goal(goalID)?.currencyCode ?? store.canvas.currencyCode
    }
}

struct PeelView: View {
    var showsClose: Bool = false
    var onClose: () -> Void = {}
    @Environment(CordonStore.self) private var store

    var body: some View {
        CoverPageCard(title: CanopyCopy.peel, showsClose: showsClose, onClose: onClose) {
            VStack(alignment: .leading, spacing: CanopyMetrics.steps(2)) {
                if let last = store.canvas.openDrops.last {
                    Text("Last drop still waiting")
                        .canopyFont(.label, bold: true)
                        .foregroundStyle(CanopyColor.muted)
                    Text(CanopyFormat.money(last.amount, code: store.canvas.currencyCode))
                        .canopyFont(.hero, bold: true)
                        .foregroundStyle(CanopyColor.accent)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Text(CanopyCopy.addedOn(CanopyFormat.dayKey(last.dayKey)))
                        .canopyFont(.body, bold: true)
                        .foregroundStyle(CanopyColor.ink)
                    Text(CanopyCopy.removingDrop(
                        CanopyFormat.money(last.amount, code: store.canvas.currencyCode),
                        goal: store.canvas.goalName
                    ))
                        .canopyFont(.body)
                        .foregroundStyle(CanopyColor.ink)
                    Spacer(minLength: CanopyMetrics.steps(2))
                    Button {
                        store.peelLastDrop()
                    } label: {
                        Text(CanopyCopy.removeDrop(CanopyFormat.money(last.amount, code: store.canvas.currencyCode)))
                            .frame(maxWidth: .infinity, minHeight: CanopyMetrics.hit)
                            .contentShape(Capsule())
                    }
                    .buttonStyle(CanopyButtonStyle(kind: .primary))
                    Button(action: onClose) {
                        Text(CanopyCopy.keepDrop)
                            .frame(maxWidth: .infinity, minHeight: CanopyMetrics.hit)
                            .contentShape(Capsule())
                    }
                    .buttonStyle(CanopyButtonStyle(kind: .secondary))
                } else {
                    Text(CanopyCopy.trayEmptyPeel)
                        .canopyFont(.display, bold: true)
                        .foregroundStyle(CanopyColor.ink)
                    Text("Add a cash drop first. You can remove only the latest drop that has not been committed.")
                        .canopyFont(.body)
                        .foregroundStyle(CanopyColor.ink)
                    Spacer(minLength: CanopyMetrics.steps(2))
                    Button(action: onClose) {
                        Text(CanopyCopy.close)
                            .frame(maxWidth: .infinity, minHeight: CanopyMetrics.hit)
                            .contentShape(Capsule())
                    }
                    .buttonStyle(CanopyButtonStyle(kind: .primary))
                }
            }
            .padding(CanopyMetrics.steps(3))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }
}

struct YYYYMMDDView: View {
    var showsClose: Bool = false
    var onClose: () -> Void = {}
    @Environment(CordonStore.self) private var store
    @State private var selected: Int?

    private var keys: [Int] {
        let raw = store.ledger.setMarks.map(\.dayKey)
            + store.ledger.dropMarks.map(\.dayKey)
            + store.ledger.hollowMarks.map(\.dayKey)
            + store.ledger.ripeMarks.map(\.dayKey)
        return Array(Set(raw)).sorted()
    }

    var body: some View {
        CoverPageCard(title: CanopyCopy.days, showsClose: showsClose, onClose: onClose) {
            ScrollView {
                VStack(alignment: .leading, spacing: CanopyMetrics.steps(2)) {
                    Text("Days with drops or commits. Open a day to see how much moved.")
                        .canopyFont(.body)
                        .foregroundStyle(CanopyColor.ink)
                    ForEach(keys, id: \.self) { key in
                        Button {
                            selected = key
                        } label: {
                            HStack(spacing: CanopyMetrics.steps(1)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(CanopyFormat.dayKey(key))
                                        .canopyFont(.body, bold: true)
                                        .foregroundStyle(CanopyColor.ink)
                                        .lineLimit(1)
                                    Text(CanopyFormat.money(amount(on: key), code: store.canvas.currencyCode))
                                        .canopyFont(.label, bold: true)
                                        .foregroundStyle(CanopyColor.accent)
                                }
                                Spacer(minLength: CanopyMetrics.steps(1))
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(CanopyColor.ink)
                                    .frame(width: CanopyMetrics.hit, height: CanopyMetrics.hit)
                            }
                            .padding(.horizontal, CanopyMetrics.steps(2))
                            .frame(maxWidth: .infinity, minHeight: CanopyMetrics.hit, alignment: .leading)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(CanopyRowStyle())
                        .background(CanopyColor.surface, in: RoundedRectangle(cornerRadius: CanopyRadius.chip, style: .continuous))
                        if selected == key {
                            Text(CanopyCopy.dayMoved(
                                CanopyCopy.dayActivity,
                                money: CanopyFormat.money(amount(on: key), code: store.canvas.currencyCode)
                            ))
                                .canopyFont(.body)
                                .foregroundStyle(CanopyColor.ink)
                        }
                    }
                }
                .padding(CanopyMetrics.steps(3))
            }
        }
    }

    private func amount(on key: Int) -> Decimal {
        let drops = store.ledger.dropMarks.filter { $0.dayKey == key }.map(\.amount)
        let commits = store.ledger.setMarks.filter { $0.dayKey == key }.map(\.amount)
        return (drops + commits).reduce(0, +)
    }
}

struct HollowMarkView: View {
    var showsClose: Bool = false
    var onClose: () -> Void = {}
    @Environment(CordonStore.self) private var store

    var body: some View {
        CoverPageCard(title: CanopyCopy.refused, showsClose: showsClose, onClose: onClose) {
            if store.ledger.hollowMarks.isEmpty {
                VStack(alignment: .leading, spacing: CanopyMetrics.steps(2)) {
                    Text(CanopyCopy.hollowEmptyTitle)
                        .canopyFont(.display, bold: true)
                        .foregroundStyle(CanopyColor.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(CanopyCopy.hollowEmptyBody)
                        .canopyFont(.body)
                        .foregroundStyle(CanopyColor.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Next, add a drop. Then come back and commit the waiting batch to your savings goal.")
                        .canopyFont(.body)
                        .foregroundStyle(CanopyColor.muted)
                    Spacer(minLength: CanopyMetrics.steps(2))
                    Button {
                        let amount = store.ledger.quickDropAmounts.first ?? 1
                        store.drop(amount: amount, dayKey: DayKey.make(from: Date()))
                    } label: {
                        Text(CanopyCopy.addDrop)
                            .frame(maxWidth: .infinity, minHeight: CanopyMetrics.hit)
                            .contentShape(Capsule())
                    }
                    .buttonStyle(CanopyButtonStyle(kind: .primary))
                }
                .padding(CanopyMetrics.steps(3))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            } else {
                markList(store.ledger.hollowMarks.map { mark in
                    MarkLine(
                        id: mark.id,
                        title: CanopyCopy.refusedWord,
                        detail: CanopyFormat.dayKey(mark.dayKey),
                        amount: CanopyFormat.plain(Decimal(store.canvas.hollowCount))
                    )
                }, emptyImage: "cdn_EmptyCanopyCutout", emptyLine: CanopyCopy.hollowEmptyBody)
            }
        }
    }
}

struct RipeMarkView: View {
    var showsClose: Bool = false
    var onClose: () -> Void = {}
    @Environment(CordonStore.self) private var store

    var body: some View {
        CoverPageCard(title: CanopyCopy.ripeTitle, showsClose: showsClose, onClose: onClose) {
            if store.ledger.ripeMarks.isEmpty {
                EmptyStateCard(
                    imageName: "cdn_RipeCrownBadge",
                    title: CanopyCopy.ripeEmptyTitle,
                    line: CanopyCopy.ripeEmptyBody,
                    actionTitle: CanopyCopy.plantGoal,
                    action: onClose
                )
            } else {
                markList(store.ledger.ripeMarks.map { mark in
                    MarkLine(
                        id: mark.id,
                        title: CanopyCopy.ripeWord,
                        detail: CanopyFormat.dayKey(mark.dayKey),
                        amount: CanopyFormat.money(mark.amount, code: store.ledger.goal(mark.goalID)?.currencyCode ?? "USD")
                    )
                }, emptyImage: "cdn_RipeCrownBadge", emptyLine: CanopyCopy.ripeEmptyBody)
            }
        }
    }
}

struct DropMarkView: View {
    var showsClose: Bool = false
    var onClose: () -> Void = {}
    @Environment(CordonStore.self) private var store

    var body: some View {
        CoverPageCard(title: CanopyCopy.dropsTitle, showsClose: showsClose, onClose: onClose) {
            markList(store.ledger.dropMarks.map { mark in
                MarkLine(
                    id: mark.id,
                    title: CanopyCopy.drop,
                    detail: CanopyFormat.dayKey(mark.dayKey),
                    amount: CanopyFormat.money(mark.amount, code: store.ledger.goal(mark.goalID)?.currencyCode ?? store.canvas.currencyCode)
                )
            }, emptyImage: "cdn_EmptyHome", emptyLine: CanopyCopy.nextTap)
        }
    }
}

struct ContinueView: View {
    var showsClose: Bool = false
    var onClose: () -> Void = {}

    var body: some View {
        CoverPageCard(title: CanopyCopy.guideTitle, showsClose: showsClose, onClose: onClose) {
            VStack(alignment: .leading, spacing: CanopyMetrics.steps(2)) {
                Image("cdn_TwistHero")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: CanopyMetrics.art, maxHeight: CanopyMetrics.art)
                    .frame(maxWidth: .infinity)
                    .accessibilityHidden(true)
                Text(CanopyCopy.guideTitle)
                    .canopyFont(.display, bold: true)
                    .foregroundStyle(CanopyColor.ink)
                Text(CanopyCopy.guideBody)
                    .canopyFont(.body)
                    .foregroundStyle(CanopyColor.muted)
                Spacer(minLength: CanopyMetrics.steps(2))
                Button(action: onClose) {
                    Text(CanopyCopy.continueTitle)
                }
                .buttonStyle(CanopyButtonStyle(kind: .primary))
            }
            .padding(CanopyMetrics.steps(3))
        }
    }
}

struct WiresView: View {
    var showsClose: Bool = false
    var onClose: () -> Void = {}
    @Environment(CordonStore.self) private var store

    var body: some View {
        CoverPageCard(title: CanopyCopy.wiresTitle, showsClose: showsClose, onClose: onClose) {
            VStack(alignment: .leading, spacing: CanopyMetrics.steps(2)) {
                Text(CanopyFormat.percent(store.canvas.progress))
                    .canopyFont(.hero, bold: true)
                    .foregroundStyle(CanopyColor.accent)
                WireBadge(fraction: Decimal(string: "0.25") ?? 0, lit: store.canvas.wiresLit.contains(.quarter))
                WireBadge(fraction: Decimal(string: "0.50") ?? 0, lit: store.canvas.wiresLit.contains(.half))
                WireBadge(fraction: Decimal(string: "0.75") ?? 0, lit: store.canvas.wiresLit.contains(.threeQuarter))
                WireBadge(fraction: 1, lit: store.canvas.wiresLit.contains(.ripe))
                Spacer(minLength: 0)
            }
            .padding(CanopyMetrics.steps(3))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }
}

struct MarkLine: Identifiable {
    var id: UUID
    var title: String
    var detail: String
    var amount: String
}

extension View {
    @ViewBuilder
    func markList(_ lines: [MarkLine], emptyImage: String, emptyLine: String) -> some View {
        if lines.isEmpty {
            EmptyStateCard(
                imageName: emptyImage,
                title: CanopyCopy.emptyTitle,
                line: emptyLine,
                actionTitle: CanopyCopy.plantGoal,
                action: {}
            )
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: CanopyMetrics.steps(1)) {
                    ForEach(lines) { line in
                        LedgerLineRow(title: line.title, detail: line.detail, amount: line.amount)
                        Rectangle()
                            .fill(CanopyColor.hairline)
                            .frame(height: CanopyMetrics.hairline)
                    }
                }
                .padding(CanopyMetrics.steps(2))
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: CanopyRadius.card, style: .continuous))
                .padding(CanopyMetrics.steps(3))
            }
        }
    }
}
