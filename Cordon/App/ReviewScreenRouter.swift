import SwiftUI

/// Reads `ReviewLaunch.screen` once, after onboarding, and opens that destination.
struct ReviewScreenRouter: View {
    @Environment(CordonStore.self) private var store
    @State private var booted = false
    @State private var didCapture = false
    @State private var capturedScreen: String?
    @State private var showHistory = false
    @State private var showGoals = false
    @State private var showPlant = false
    @State private var showSettings = false
    @State private var replayIntro = false
    @State private var showBootSpinner = false

    var body: some View {
        Group {
            if !booted {
                boot
            } else if replayIntro || (!store.ledger.onboardingComplete && capturedScreen == nil) {
                OnboardingCanopyView {
                    store.completeOnboarding()
                    replayIntro = false
                    captureIfNeeded()
                }
            } else {
                destination
            }
        }
        .preferredColorScheme(.dark)
        .task {
            let spinner = Task { @MainActor in
                try? await Task.sleep(nanoseconds: 150_000_000)
                if !booted { showBootSpinner = true }
            }
            await store.bootstrap()
            spinner.cancel()
            if store.ledger.onboardingComplete {
                captureIfNeeded()
            }
            booted = true
        }
    }

    private var boot: some View {
        VStack(alignment: .leading, spacing: CanopyMetrics.steps(2)) {
            RoundedRectangle(cornerRadius: CanopyRadius.card, style: .continuous)
                .fill(CanopyColor.surface)
                .frame(height: CanopyMetrics.heroHeight)
                .redacted(reason: .placeholder)
            if showBootSpinner {
                ProgressView()
                    .tint(CanopyColor.accent)
            }
        }
        .padding(CanopyMetrics.steps(3))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(CanopyColor.background.ignoresSafeArea())
    }

    @ViewBuilder
    private var destination: some View {
        switch capturedScreen {
        case "log":
            ledgerPage
        case "goals":
            GoalsBoardView(onPlant: { showPlant = true })
                .sheet(isPresented: $showPlant) { plantSheet }
        case "settings", "settingssheetview":
            SettingsSheetView(onReplayIntro: { replayIntro = true })
        case "plant", "goalplantsheetview":
            GoalPlantSheetView()
        case "wires":
            WiresView()
        case "canopyrootview":
            home(focus: .vine, chrome: false)
        case "setmark":
            SetMarkView()
        case "tray":
            TrayView()
        case "peel":
            PeelView()
        case "analyticssheetview", "analytics":
            AnalyticsSheetView()
        case "yyyymmdd":
            YYYYMMDDView()
        case "hollowmark":
            HollowMarkView()
        case "ripemark":
            RipeMarkView()
        case "dropmark":
            DropMarkView()
        case "onboardingcanopyview":
            OnboardingCanopyView {
                store.completeOnboarding()
            }
        case "continue":
            ContinueView()
        default:
            home(focus: .live, chrome: true)
        }
    }

    private var ledgerPage: some View {
        CoverPageCard(title: CanopyCopy.ledger, showsClose: false, onClose: {}) {
            ScrollView {
                VStack(alignment: .leading, spacing: CanopyMetrics.steps(2)) {
                    Text(CanopyCopy.savedNow)
                        .canopyFont(.label, bold: true)
                        .foregroundStyle(CanopyColor.muted)
                    Text(CanopyFormat.money(store.canvas.canopyTotal, code: store.canvas.currencyCode))
                        .canopyFont(.hero, bold: true)
                        .foregroundStyle(CanopyColor.accent)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Text(CanopyCopy.waitingTray(CanopyFormat.money(store.canvas.tray, code: store.canvas.currencyCode)))
                        .canopyFont(.body)
                        .foregroundStyle(CanopyColor.ink)
                    Button(action: addLedgerDrop) {
                        Text(CanopyCopy.addDrop)
                            .frame(maxWidth: .infinity, minHeight: CanopyMetrics.hit)
                            .contentShape(Capsule())
                    }
                    .buttonStyle(CanopyButtonStyle(kind: .primary))
                    Button(action: commitLedger) {
                        Text(CanopyCopy.commitMoney(CanopyFormat.money(store.canvas.tray, code: store.canvas.currencyCode)))
                            .frame(maxWidth: .infinity, minHeight: CanopyMetrics.hit)
                            .contentShape(Capsule())
                    }
                    .buttonStyle(CanopyButtonStyle(kind: .secondary))
                    .disabled(!store.canvas.setCanopyEnabled)
                    HStack(spacing: CanopyMetrics.steps(1)) {
                        filterChip(CanopyCopy.allActivity, tag: "all")
                        filterChip(CanopyCopy.commits, tag: "commits")
                        filterChip(CanopyCopy.dropsTitle, tag: "drops")
                    }
                    ForEach(filteredLog) { line in
                        Button(action: { inspected = line.id }) {
                            LedgerLineRow(title: line.title, detail: line.detail, amount: line.amount)
                                .frame(maxWidth: .infinity, minHeight: CanopyMetrics.hit, alignment: .leading)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(CanopyRowStyle())
                    }
                }
                .padding(CanopyMetrics.steps(3))
            }
        }
    }

    @State private var ledgerFilter = "all"
    @State private var inspected: UUID?

    private func filterChip(_ title: String, tag: String) -> some View {
        Button {
            ledgerFilter = tag
        } label: {
            Text(title)
        }
        .buttonStyle(CanopyChipStyle(selected: ledgerFilter == tag))
    }

    private var filteredLog: [MarkLine] {
        switch ledgerFilter {
        case "commits": return logLines.filter { $0.title == CanopyCopy.commitWord }
        case "drops": return logLines.filter { $0.title == CanopyCopy.drop }
        default: return logLines
        }
    }

    private func addLedgerDrop() {
        let amount = store.ledger.quickDropAmounts.first ?? 1
        store.drop(amount: amount, dayKey: DayKey.make(from: Date()))
    }

    private func commitLedger() {
        guard store.canvas.setCanopyEnabled else { return }
        store.setCanopy(dayKey: DayKey.make(from: Date()))
    }

    private var logLines: [MarkLine] {
        var lines: [MarkLine] = []
        for mark in store.ledger.setMarks {
            lines.append(MarkLine(
                id: mark.id,
                title: CanopyCopy.commitWord,
                detail: CanopyFormat.dayKey(mark.dayKey),
                amount: CanopyFormat.money(mark.amount, code: store.ledger.goal(mark.goalID)?.currencyCode ?? "USD")
            ))
        }
        for mark in store.ledger.dropMarks where !mark.settled {
            lines.append(MarkLine(
                id: mark.id,
                title: CanopyCopy.drop,
                detail: CanopyFormat.dayKey(mark.dayKey),
                amount: CanopyFormat.money(mark.amount, code: store.ledger.goal(mark.goalID)?.currencyCode ?? "USD")
            ))
        }
        return lines
    }

    private func home(focus: CanopyRootView.Focus, chrome: Bool) -> some View {
        NavigationStack {
            CanopyRootView(
                focus: focus,
                showsChrome: chrome,
                onHistory: { showHistory = true },
                onGoals: { showGoals = true },
                onSettings: { showSettings = true },
                onPlant: { showPlant = true }
            )
        }
        .sheet(isPresented: $showHistory) {
            AnalyticsSheetView(showsClose: true, onClose: { showHistory = false })
        }
        .sheet(isPresented: $showGoals) {
            GoalsBoardView(showsClose: true, onClose: { showGoals = false }, onPlant: {
                showGoals = false
                showPlant = true
            })
        }
        .sheet(isPresented: $showPlant) {
            GoalPlantSheetView(showsClose: true, onClose: { showPlant = false })
        }
        .sheet(isPresented: $showSettings) {
            SettingsSheetView(showsClose: true, onClose: { showSettings = false }, onReplayIntro: {
                showSettings = false
                replayIntro = true
            })
        }
    }

    private var plantSheet: some View {
        GoalPlantSheetView(showsClose: true, onClose: { showPlant = false })
    }

    private func captureIfNeeded() {
        guard !didCapture else { return }
        didCapture = true
        capturedScreen = ReviewLaunch.screen
    }
}
