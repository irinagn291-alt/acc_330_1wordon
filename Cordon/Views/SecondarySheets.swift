import SwiftUI
import UIKit

/// Committed batches, wire crossings, and refused counts.
struct AnalyticsSheetView: View {
    var showsClose: Bool = false
    var onClose: () -> Void = {}

    @Environment(CordonStore.self) private var store

    private var canvas: CordonCanvasState { store.canvas }

    var body: some View {
        CoverPageCard(title: CanopyCopy.history, showsClose: showsClose, onClose: onClose) {
            Group {
                if canvas.isUnstaked {
                    EmptyStateCard(
                        imageName: "cdn_EmptyCanopyCutout",
                        title: CanopyCopy.emptyTitle,
                        line: CanopyCopy.emptyBody,
                        actionTitle: CanopyCopy.plantFirst,
                        action: onClose
                    )
                } else if canvas.setMarks.isEmpty {
                    EmptyStateCard(
                        imageName: "cdn_TwistHero",
                        title: CanopyCopy.commits,
                        line: CanopyCopy.nextTap,
                        actionTitle: CanopyCopy.setCanopy,
                        action: onClose
                    )
                } else {
                    filled
                }
            }
        }
    }

    private var filled: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CanopyMetrics.steps(2)) {
                if let message = canvas.statusMessage, isFailure(message) {
                    StatusBannerRow(message: message, showsRetry: true) {
                        Task { await store.flush() }
                    }
                }
                CanopyChartCard(marks: canvas.setMarks, code: canvas.currencyCode)
                VStack(alignment: .leading, spacing: CanopyMetrics.steps(1)) {
                    Text("Commit milestones")
                        .canopyFont(.title, bold: true)
                        .foregroundStyle(CanopyColor.ink)
                    ForEach(canvas.setMarks) { mark in
                        LedgerLineRow(
                            title: CanopyFormat.dayKey(mark.dayKey),
                            detail: wireDetail(mark),
                            amount: CanopyFormat.money(mark.amount, code: canvas.currencyCode),
                            accentAmount: !mark.wiresCrossed.isEmpty
                        )
                    }
                    LedgerLineRow(
                        title: "Refused commits",
                        detail: canvas.hollowCount == 0 ? "None on this goal" : "Empty-tray commits",
                        amount: "\(canvas.hollowCount)"
                    )
                }
                .padding(CanopyMetrics.steps(2))
                .background(CanopyColor.surface, in: RoundedRectangle(cornerRadius: CanopyRadius.card, style: .continuous))
                Button(action: historyAction) {
                    Text(showsClose ? CanopyCopy.close : CanopyCopy.commitTray)
                        .frame(maxWidth: .infinity, minHeight: CanopyMetrics.hit)
                        .contentShape(Capsule())
                }
                .buttonStyle(CanopyButtonStyle(kind: .primary))
                .disabled(!showsClose && !canvas.setCanopyEnabled)
            }
            .padding(CanopyMetrics.steps(3))
        }
    }

    private func historyAction() {
        if showsClose {
            onClose()
            return
        }
        guard canvas.setCanopyEnabled else { return }
        store.setCanopy(dayKey: DayKey.make(from: Date()))
    }

    private func wireDetail(_ mark: SetMark) -> String {
        if mark.wiresCrossed.isEmpty {
            return "Committed before the first quarter"
        }
        return "Crossed " + mark.wiresCrossed.map { CanopyFormat.percent($0.threshold) }.joined(separator: ", ")
    }

    private func isFailure(_ message: String) -> Bool {
        message.contains(CanopyCopy.couldNot) || message.contains(CanopyCopy.tryAgain)
    }
}

/// Create or switch a goal. Ripe is the fold, shown here when the target is met.
struct GoalPlantSheetView: View {
    var showsClose: Bool = false
    var onClose: () -> Void = {}

    @Environment(CordonStore.self) private var store
    @State private var name = ""
    @State private var targetText = ""
    @State private var currency = "USD"
    @State private var seedText = ""
    @State private var error = ""
    @FocusState private var focused: Bool

    var body: some View {
        CoverPageCard(title: CanopyCopy.plantGoal, showsClose: showsClose, onClose: onClose) {
            ScrollView {
                VStack(alignment: .leading, spacing: CanopyMetrics.steps(2)) {
                    if !error.isEmpty {
                        StatusBannerRow(message: error, showsRetry: true) {
                            error = ""
                            plant()
                        }
                    }
                    field(CanopyCopy.goals, text: $name, keyboard: .default, caps: .sentences)
                    field(CanopyCopy.target, text: $targetText, keyboard: .decimalPad, caps: .never)
                    field(CanopyCopy.currency, text: $currency, keyboard: .asciiCapable, caps: .characters)
                    field(CanopyCopy.vineNumber, text: $seedText, keyboard: .numberPad, caps: .never)
                    if let goal = store.ledger.activeGoal {
                        LedgerLineRow(
                            title: goal.name,
                            detail: CanopyCopy.phase(store.canvas.phase),
                            amount: CanopyFormat.money(goal.targetAmount, code: goal.currencyCode),
                            accentAmount: store.canvas.phase == .canopied
                        )
                    }
                    Button(action: plant) {
                        Text(CanopyCopy.plantGoal)
                    }
                    .buttonStyle(CanopyButtonStyle(kind: .primary))
                }
                .padding(CanopyMetrics.steps(3))
            }
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(CanopyCopy.close) { focused = false }
                }
            }
        }
    }

    private func field(
        _ title: String,
        text: Binding<String>,
        keyboard: UIKeyboardType,
        caps: TextInputAutocapitalization
    ) -> some View {
        VStack(alignment: .leading, spacing: CanopyMetrics.steps(1)) {
            Text(title)
                .canopyFont(.label, bold: true)
                .foregroundStyle(CanopyColor.muted)
            TextField(title, text: text)
                .canopyFont(.body, bold: true)
                .foregroundStyle(CanopyColor.ink)
                .keyboardType(keyboard)
                .textInputAutocapitalization(caps)
                .focused($focused)
                .frame(minHeight: CanopyMetrics.hit)
                .padding(.horizontal, CanopyMetrics.steps(2))
                .background(CanopyColor.surface, in: RoundedRectangle(cornerRadius: CanopyRadius.chip, style: .continuous))
        }
    }

    private func plant() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            error = CanopyCopy.nameInvalid
            return
        }
        guard let target = CanopyFormat.parseDecimal(targetText) else {
            error = CanopyCopy.targetInvalid
            return
        }
        let code = currency.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard code.count == 3, code.allSatisfy(\.isLetter) else {
            error = CanopyCopy.codeInvalid
            return
        }
        let seed: UInt64
        let seedTrim = seedText.trimmingCharacters(in: .whitespacesAndNewlines)
        if seedTrim.isEmpty {
            seed = UInt64.random(in: 1...UInt64.max)
        } else if let parsed = UInt64(seedTrim.filter(\.isNumber)), !seedTrim.filter(\.isNumber).isEmpty {
            seed = parsed
        } else {
            error = CanopyCopy.seedInvalid
            return
        }
        let goal = CordonGoal(
            name: trimmed,
            targetAmount: target,
            currencyCode: code,
            vineSeed: seed,
            plantedDayKey: DayKey.make(from: Date())
        )
        store.plant(goal)
        CommitHaptic.success()
        error = ""
        name = ""
        targetText = ""
        seedText = ""
        onClose()
    }
}

struct SettingsSheetView: View {
    var showsClose: Bool = false
    var onClose: () -> Void = {}
    var onReplayIntro: () -> Void = {}

    @Environment(CordonStore.self) private var store
    @State private var exportError = ""
    @State private var exporting = false
    @State private var showExportSpinner = false
    @State private var resetting = false
    @State private var confirmReset = false
    @State private var shareURL: URL?
    @State private var quickText = ""
    @FocusState private var focused: Bool

    var body: some View {
        CoverPageCard(title: CanopyCopy.settings, showsClose: showsClose, onClose: onClose) {
            ScrollView {
                VStack(alignment: .leading, spacing: CanopyMetrics.steps(2)) {
                    if !exportError.isEmpty {
                        StatusBannerRow(message: exportError, showsRetry: true) {
                            Task { await export() }
                        }
                    }
                    if let message = store.canvas.statusMessage, isFailure(message) {
                        StatusBannerRow(message: message, showsRetry: true) {
                            Task { await store.flush() }
                        }
                    }
                    VStack(alignment: .leading, spacing: CanopyMetrics.steps(1)) {
                        Text(CanopyCopy.quickDrops)
                            .canopyFont(.label, bold: true)
                            .foregroundStyle(CanopyColor.muted)
                        ForEach(store.ledger.quickDropAmounts, id: \.self) { amount in
                            LedgerLineRow(
                                title: CanopyCopy.amount,
                                detail: CanopyCopy.drop,
                                amount: CanopyFormat.money(amount, code: store.canvas.currencyCode)
                            )
                        }
                        TextField(CanopyCopy.addAmount, text: $quickText)
                            .canopyFont(.body)
                            .foregroundStyle(CanopyColor.ink)
                            .keyboardType(.decimalPad)
                            .focused($focused)
                            .frame(minHeight: CanopyMetrics.hit)
                        Button(action: addQuick) {
                            Text(CanopyCopy.addAmount)
                        }
                        .buttonStyle(CanopyButtonStyle(kind: .secondary))
                        .disabled(CanopyFormat.parseDecimal(quickText) == nil)
                    }
                    .padding(CanopyMetrics.steps(2))
                    .background(CanopyColor.surface, in: RoundedRectangle(cornerRadius: CanopyRadius.card, style: .continuous))

                    Button(action: { Task { await export() } }) {
                        if showExportSpinner {
                            ProgressView().tint(CanopyColor.background)
                        } else {
                            Label(CanopyCopy.export, systemImage: "square.and.arrow.up")
                        }
                    }
                    .buttonStyle(CanopyButtonStyle(kind: .primary))
                    .disabled(exporting || resetting)

                    Button(action: onReplayIntro) {
                        Text(CanopyCopy.intro)
                    }
                    .buttonStyle(CanopyButtonStyle(kind: .secondary))

                    Button {
                        guard let url = URL(string: CanopyCopy.contactURL) else { return }
                        UIApplication.shared.open(url)
                    } label: {
                        Label(CanopyCopy.contact, systemImage: "link")
                    }
                    .buttonStyle(CanopyButtonStyle(kind: .secondary))

                    Button(action: { confirmReset = true }) {
                        Label(CanopyCopy.reset, systemImage: "trash")
                    }
                    .buttonStyle(CanopyButtonStyle(kind: .destructive))
                    .disabled(resetting || exporting)

                    Text(CanopyCopy.support)
                        .canopyFont(.label)
                        .foregroundStyle(CanopyColor.muted)
                }
                .padding(CanopyMetrics.steps(3))
            }
            .scrollDismissesKeyboard(.interactively)
            .confirmationDialog(CanopyCopy.resetTitle, isPresented: $confirmReset, titleVisibility: .visible) {
                Button(CanopyCopy.reset, role: .destructive) {
                    Task { await reset() }
                }
                Button(CanopyCopy.close, role: .cancel) {}
            } message: {
                Text(CanopyCopy.resetBody)
            }
            .sheet(item: shareItem) { item in
                ExportShareCard(url: item.url)
                    .ignoresSafeArea()
            }
        }
    }

    private var shareItem: Binding<ShareLinkItem?> {
        Binding(
            get: { shareURL.map(ShareLinkItem.init(url:)) },
            set: { shareURL = $0?.url }
        )
    }

    private func addQuick() {
        guard let amount = CanopyFormat.parseDecimal(quickText) else {
            exportError = CanopyCopy.amountInvalid
            return
        }
        var next = store.ledger.quickDropAmounts
        next.append(amount)
        store.replaceQuickDrops(next)
        quickText = ""
        focused = false
        exportError = ""
    }

    private func export() async {
        guard !exporting else { return }
        exporting = true
        exportError = ""
        showExportSpinner = false
        let spinner = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 150_000_000)
            if exporting { showExportSpinner = true }
        }
        do {
            let url = try await store.exportCSV(to: FileManager.default.temporaryDirectory)
            spinner.cancel()
            showExportSpinner = false
            shareURL = url
        } catch {
            spinner.cancel()
            showExportSpinner = false
            exportError = CanopyCopy.exportFailed
        }
        exporting = false
    }

    private func reset() async {
        guard !resetting else { return }
        resetting = true
        await store.resetAllData()
        resetting = false
    }

    private func isFailure(_ message: String) -> Bool {
        message.contains(CanopyCopy.couldNot) || message.contains(CanopyCopy.tryAgain)
    }
}

struct ShareLinkItem: Identifiable {
    var url: URL
    var id: String { url.absoluteString }
}

struct OnboardingCanopyView: View {
    var onFinish: () -> Void

    @State private var page = 0

    private var pages: [(String, String, String)] {
        [
            ("cdn_Onboarding1", CanopyCopy.page1Title, CanopyCopy.page1Body),
            ("cdn_Onboarding2", CanopyCopy.page2Title, CanopyCopy.page2Body),
            ("cdn_Onboarding3", CanopyCopy.page3Title, CanopyCopy.page3Body)
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: CanopyMetrics.steps(2)) {
            HStack {
                Spacer()
                Button(action: onFinish) {
                    Text(CanopyCopy.skip)
                        .frame(minWidth: CanopyMetrics.hit, minHeight: CanopyMetrics.hit)
                }
                .buttonStyle(CanopyButtonStyle(kind: .secondary, fills: false))
            }
            let item = pages[page]
            Image(item.0)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: CanopyMetrics.vineTall)
                .accessibilityHidden(true)
            Text(item.1)
                .canopyFont(.display, bold: true)
                .foregroundStyle(CanopyColor.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(item.2)
                .canopyFont(.body)
                .foregroundStyle(CanopyColor.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer(minLength: CanopyMetrics.steps(2))
            Button(action: advance) {
                Text(page == pages.count - 1 ? CanopyCopy.continueTitle : CanopyCopy.next)
            }
            .buttonStyle(CanopyButtonStyle(kind: .primary))
        }
        .padding(CanopyMetrics.steps(3))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(CanopyColor.background.ignoresSafeArea())
    }

    private func advance() {
        if page < pages.count - 1 {
            page += 1
        } else {
            onFinish()
        }
    }
}
