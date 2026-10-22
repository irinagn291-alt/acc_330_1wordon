import SwiftUI
import UIKit

/// Root canvas. The vine and particle field live only here.
struct CanopyRootView: View {
    enum Focus {
        case live
        case vine
    }

    var focus: Focus = .live
    var showsChrome: Bool = true
    var onHistory: () -> Void = {}
    var onGoals: () -> Void = {}
    var onSettings: () -> Void = {}
    var onPlant: () -> Void = {}

    @Environment(CordonStore.self) private var store
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.scenePhase) private var scenePhase
    @FocusState private var amountFocused: Bool
    @State private var amountText = ""
    @State private var locked = false
    @State private var swell = false
    @State private var confirmPeel = false
    @State private var dayKey = DayKey.make(from: Date())

    private var canvas: CordonCanvasState { store.canvas }

    var body: some View {
        Group {
            if canvas.isUnstaked {
                EmptyStateCard(
                    imageName: "cdn_EmptyHome",
                    title: CanopyCopy.emptyTitle,
                    line: CanopyCopy.emptyBody,
                    actionTitle: CanopyCopy.plantFirst,
                    action: onPlant
                )
            } else {
                live
            }
        }
        .background(CanopyColor.background.ignoresSafeArea())
        .navigationTitle(CanopyCopy.garden)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            if showsChrome && !canvas.isUnstaked {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: onHistory) {
                        Image(systemName: "list.bullet.rectangle")
                            .frame(minWidth: CanopyMetrics.hit, minHeight: CanopyMetrics.hit)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel(CanopyCopy.openHistory)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onGoals) {
                        Image(systemName: "target")
                            .frame(minWidth: CanopyMetrics.hit, minHeight: CanopyMetrics.hit)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel(CanopyCopy.goals)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onSettings) {
                        Image(systemName: "gearshape")
                            .frame(minWidth: CanopyMetrics.hit, minHeight: CanopyMetrics.hit)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel(CanopyCopy.settings)
                }
            }
        }
        .toolbarBackground(.regularMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .confirmationDialog(CanopyCopy.peelConfirmTitle, isPresented: $confirmPeel, titleVisibility: .visible) {
            Button(CanopyCopy.peel, role: .destructive) { performPeel() }
            Button(CanopyCopy.close, role: .cancel) {}
        } message: {
            Text(CanopyCopy.peelConfirmBody)
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            dayKey = DayKey.make(from: Date())
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
            dayKey = DayKey.make(from: Date())
        }
    }

    private var live: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: CanopyMetrics.steps(2)) {
                    headline
                    goalRail
                    if sizeClass == .regular && focus == .live {
                        HStack(alignment: .top, spacing: CanopyMetrics.steps(2)) {
                            VStack(alignment: .leading, spacing: CanopyMetrics.steps(2)) {
                                vineHero
                                wireRail
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            VStack(alignment: .leading, spacing: CanopyMetrics.steps(2)) {
                                CanopyChartCard(marks: canvas.setMarks, code: canvas.currencyCode)
                                trayLedger
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    } else if focus == .vine {
                        vineHero
                        wireRail
                        primaryCommit
                    } else {
                        vineHero
                        wireRail
                        primaryCommit
                        CanopyChartCard(marks: canvas.setMarks, code: canvas.currencyCode)
                        trayLedger
                    }
                    if focus == .live {
                        FusedActionStripCard(
                            amountText: $amountText,
                            focused: $amountFocused,
                            quickAmounts: store.ledger.quickDropAmounts,
                            code: canvas.currencyCode,
                            setEnabled: canvas.setCanopyEnabled,
                            peelEnabled: canvas.peelEnabled,
                            dropEnabled: canvas.phase != .canopied,
                            locked: locked,
                            onQuick: { amount in
                                amountText = CanopyFormat.plain(amount)
                                performDrop(amount)
                            },
                            onDrop: {
                                guard let amount = CanopyFormat.parseDecimal(amountText) else { return }
                                performDrop(amount)
                            },
                            onPeel: { confirmPeel = true },
                            onSet: performSet
                        )
                        .id("amount-field")
                    }
                    if let message = canvas.statusMessage {
                        StatusBannerRow(message: message, showsRetry: isFailure(message)) {
                            Task { await store.flush() }
                        }
                    }
                }
                .padding(CanopyMetrics.steps(3))
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: amountFocused) { _, focused in
                guard focused else { return }
                withAnimation(CanopyMotion.ease(reduceMotion: reduceMotion)) {
                    proxy.scrollTo("amount-field", anchor: .center)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(CanopyCopy.close) { amountFocused = false }
                    .frame(minWidth: CanopyMetrics.hit, minHeight: CanopyMetrics.hit)
            }
        }
    }

    private var headline: some View {
        VStack(alignment: .leading, spacing: CanopyMetrics.steps(1)) {
            Text(CanopyCopy.job)
                .canopyFont(.display, bold: true)
                .foregroundStyle(CanopyColor.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(CanopyCopy.nextTap)
                .canopyFont(.body)
                .foregroundStyle(CanopyColor.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .layoutPriority(1)
        .onTapGesture { amountFocused = false }
    }

    private var goalRail: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CanopyMetrics.steps(1)) {
                ForEach(store.ledger.goals) { goal in
                    Button {
                        store.activate(goal.id)
                    } label: {
                        Text(goal.name)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    .buttonStyle(CanopyChipStyle(selected: goal.id == store.ledger.activeGoalID))
                    .frame(maxWidth: CanopyMetrics.art)
                }
                Button(action: onPlant) {
                    Label(CanopyCopy.plantGoal, systemImage: "plus")
                        .lineLimit(1)
                }
                .buttonStyle(CanopyChipStyle())
            }
        }
    }

    private var vineHero: some View {
        VStack(alignment: .leading, spacing: CanopyMetrics.steps(2)) {
            VStack(alignment: .leading, spacing: CanopyMetrics.steps(1)) {
                HStack(alignment: .firstTextBaseline, spacing: CanopyMetrics.steps(1)) {
                    Text(canvas.goalName)
                        .canopyFont(.title, bold: true)
                        .foregroundStyle(CanopyColor.ink)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(CanopyCopy.phase(canvas.phase))
                        .canopyFont(.label, bold: true)
                        .foregroundStyle(CanopyColor.background)
                        .lineLimit(1)
                        .padding(.horizontal, CanopyMetrics.steps(1))
                        .frame(minHeight: CanopyMetrics.hit)
                        .background(CanopyColor.accent, in: Capsule())
                }
                Text(CanopyCopy.savedNow)
                    .canopyFont(.label, bold: true)
                    .foregroundStyle(CanopyColor.muted)
                Text(CanopyFormat.money(canvas.canopyTotal, code: canvas.currencyCode))
                    .canopyFont(.hero, bold: true)
                    .foregroundStyle(CanopyColor.accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(CanopyCopy.goalTarget(CanopyFormat.money(canvas.target, code: canvas.currencyCode)))
                    .canopyFont(.title, bold: true)
                    .foregroundStyle(CanopyColor.ink)
                    .lineLimit(1)
                progressTrack
            }
            .padding(CanopyMetrics.steps(2))
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(CanopyColor.surface)

            VineCanvasHost(
                shape: canvas.vine,
                progress: NSDecimalNumber(decimal: canvas.progress).doubleValue
            )
            .frame(height: 112)
            .frame(maxWidth: .infinity)
            .background(CanopyColor.background)
            .scaleEffect(reduceMotion ? 1 : (swell ? CanopyMotion.swellScale : 1), anchor: .bottom)
            .opacity(reduceMotion && swell ? 0.55 : 1)
            .animation(CanopyMotion.commit(reduceMotion: reduceMotion), value: swell)
            .clipped()
            .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity)
        .background(CanopyColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: CanopyRadius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: CanopyRadius.card, style: .continuous)
                .stroke(CanopyColor.hairline, lineWidth: CanopyMetrics.hairline)
        }
        .accessibilityElement(children: .combine)
    }

    private var progressTrack: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(CanopyColor.background)
                Capsule()
                    .fill(CanopyColor.accent)
                    .frame(width: max(8, geo.size.width * CGFloat(NSDecimalNumber(decimal: min(max(canvas.progress, 0), 1)).doubleValue)))
            }
        }
        .frame(height: 12)
        .accessibilityLabel(CanopyFormat.percent(canvas.progress))
    }

    private var primaryCommit: some View {
        Button(action: performSet) {
            Text(commitTitle)
                .frame(maxWidth: .infinity, minHeight: CanopyMetrics.hit)
                .contentShape(Capsule())
        }
        .buttonStyle(CanopyButtonStyle(kind: .primary))
        .disabled(!canvas.setCanopyEnabled || locked)
    }

    private var commitTitle: String {
        if canvas.setCanopyEnabled {
            return "Commit \(CanopyFormat.money(canvas.tray, code: canvas.currencyCode)) to \(canvas.goalName)"
        }
        return CanopyCopy.setCanopy
    }

    private var wireRail: some View {
        let wires: [(CanopyWire, Decimal)] = [
            (.quarter, Decimal(string: "0.25") ?? 0),
            (.half, Decimal(string: "0.5") ?? 0),
            (.threeQuarter, Decimal(string: "0.75") ?? 0),
            (.ripe, 1)
        ]
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CanopyMetrics.steps(1)) {
                ForEach(wires, id: \.0) { wire, fraction in
                    WireBadge(fraction: fraction, lit: canvas.wiresLit.contains(wire))
                }
            }
        }
    }

    private var trayLedger: some View {
        VStack(alignment: .leading, spacing: CanopyMetrics.steps(1)) {
            Text(CanopyCopy.trayHeading)
                .canopyFont(.label, bold: true)
                .foregroundStyle(CanopyColor.muted)
            if canvas.openDrops.isEmpty {
                Text(CanopyCopy.phaseOpen)
                    .canopyFont(.body)
                    .foregroundStyle(CanopyColor.ink)
                    .frame(maxWidth: .infinity, minHeight: CanopyMetrics.hit, alignment: .leading)
            } else {
                ForEach(canvas.openDrops) { drop in
                    LedgerLineRow(
                        title: CanopyCopy.drop,
                        detail: CanopyFormat.dayKey(drop.dayKey),
                        amount: CanopyFormat.money(drop.amount, code: canvas.currencyCode)
                    )
                    Rectangle()
                        .fill(CanopyColor.hairline)
                        .frame(height: CanopyMetrics.hairline)
                }
            }
            LedgerLineRow(
                title: CanopyCopy.waiting,
                detail: CanopyCopy.phase(canvas.phase),
                amount: CanopyFormat.money(canvas.tray, code: canvas.currencyCode),
                accentAmount: true
            )
        }
        .padding(CanopyMetrics.steps(2))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CanopyColor.surface, in: RoundedRectangle(cornerRadius: CanopyRadius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: CanopyRadius.card, style: .continuous)
                .stroke(CanopyColor.hairline, lineWidth: CanopyMetrics.hairline)
        }
    }

    private func performDrop(_ amount: Decimal) {
        guard !locked else { return }
        locked = true
        let before = canvas.openDrops.count
        store.drop(amount: amount, dayKey: dayKey)
        if store.canvas.openDrops.count > before {
            CommitHaptic.success()
            amountText = ""
            amountFocused = false
        }
        locked = false
    }

    private func performSet() {
        guard !locked, canvas.setCanopyEnabled else { return }
        locked = true
        let before = canvas.setMarks.count
        store.setCanopy(dayKey: dayKey)
        if store.canvas.setMarks.count > before {
            CommitHaptic.success()
            swell = true
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 420_000_000)
                swell = false
            }
        }
        locked = false
    }

    private func performPeel() {
        guard !locked else { return }
        locked = true
        store.peelLastDrop()
        locked = false
    }

    private func isFailure(_ message: String) -> Bool {
        message.contains(CanopyCopy.couldNot) || message.contains(CanopyCopy.tryAgain)
    }
}
