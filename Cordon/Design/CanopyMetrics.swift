import SwiftUI
import UIKit

/// Spacing, type, radius, and motion. Views reach tokens only through these accessors.
enum CanopyStep {
    case hero
    case display
    case title
    case body
    case label
    case micro
}

enum CanopyMetrics {
    static let unit: CGFloat = 8
    static let hit: CGFloat = 44
    static let hairline: CGFloat = 1
    static let vineStroke: CGFloat = 3
    static let heroHeight: CGFloat = 288
    static let vineTall: CGFloat = 480
    static let chartHeight: CGFloat = 160
    static let art: CGFloat = 240
    static let dot: CGFloat = 8

    static func steps(_ count: Int) -> CGFloat {
        unit * CGFloat(count)
    }
}

enum CanopyRadius {
    static let card: CGFloat = 32
    static let chip: CGFloat = 16
}

enum CanopyColor {
    static var background: Color { DesignTokens.bg }
    static var surface: Color { DesignTokens.surface }
    static var ink: Color { DesignTokens.ink }
    static var accent: Color { DesignTokens.accent }
    static var muted: Color { DesignTokens.muted }
    static var hairline: Color { DesignTokens.muted.opacity(0.45) }
}

enum CanopyType {
    static let heroBase: CGFloat = 56
    static let displayBase: CGFloat = 32
    static let titleBase: CGFloat = 20
    static let bodyBase: CGFloat = 17
    static let labelBase: CGFloat = 13
    static let microBase: CGFloat = 11
    static let tight: CGFloat = -0.6

    static func font(size: CGFloat, bold: Bool) -> Font {
        Font.custom(DesignTokens.fontFamily, size: size).weight(bold ? .bold : .regular)
    }
}

enum CanopyMotion {
    static let pressScale: CGFloat = 0.97
    static let swellScale: CGFloat = 1.04

    static func commit(reduceMotion: Bool) -> Animation {
        if reduceMotion {
            return .easeOut(duration: 0.25)
        }
        return .spring(response: 0.4, dampingFraction: 0.8)
    }

    static func ease(reduceMotion: Bool) -> Animation {
        .easeOut(duration: reduceMotion ? 0.2 : 0.28)
    }
}

struct CanopyFont: ViewModifier {
    var step: CanopyStep
    var bold: Bool = false

    @ScaledMetric(relativeTo: .largeTitle) private var hero = CanopyType.heroBase
    @ScaledMetric(relativeTo: .title) private var display = CanopyType.displayBase
    @ScaledMetric(relativeTo: .title2) private var title = CanopyType.titleBase
    @ScaledMetric(relativeTo: .body) private var body = CanopyType.bodyBase
    @ScaledMetric(relativeTo: .footnote) private var label = CanopyType.labelBase
    @ScaledMetric(relativeTo: .caption) private var micro = CanopyType.microBase

    private var size: CGFloat {
        switch step {
        case .hero: hero
        case .display: display
        case .title: title
        case .body: body
        case .label: label
        case .micro: micro
        }
    }

    private var tracking: CGFloat {
        switch step {
        case .hero, .display, .label: CanopyType.tight
        default: 0
        }
    }

    func body(content: Content) -> some View {
        content
            .font(CanopyType.font(size: size, bold: bold))
            .tracking(tracking)
            .fixedSize(horizontal: false, vertical: true)
    }
}

extension View {
    func canopyFont(_ step: CanopyStep, bold: Bool = false) -> some View {
        modifier(CanopyFont(step: step, bold: bold))
    }
}

/// User-facing phrases. Kept outside `Text`/`Button` literals so the product words stay on screen.
enum CanopyCopy {
    static let setCanopy = "Set Canopy"
    static let peel = "Peel"
    static let peelConfirmTitle = "Peel the last drop?"
    static let peelConfirmBody = "Removing this drop lowers the waiting tray. Cash already committed to the goal stays saved."
    static let trayHeading = "Tray"
    static let job = "Save loose cash by hand."
    static let nextTap = "Drops are waiting. Set the batch to grow the vine."
    static let emptyTitle = "The garden is empty."
    static let emptyBody = "Plant your first goal."
    static let plantFirst = "Plant First Goal"
    static let plantGoal = "Plant Goal"
    static let drop = "Drop"
    static let close = "Close"
    static let reset = "Reset all data"
    static let resetTitle = "Reset the garden?"
    static let resetBody = "Goals and cash records are deleted from this device."
    static let contact = "Contact"
    static let contactURL = "https://cordon-canopy.pro/contact-us"
    static let export = "Export CSV"
    static let settings = "Settings"
    static let garden = "Garden"
    static let ledger = "Ledger"
    static let goals = "Goals"
    static let history = "History"
    static let days = "Days"
    static let commits = "Commits"
    static let waiting = "Waiting cash"
    static let refused = "Refused sets"
    static let ripeTitle = "Ripe refusals"
    static let dropsTitle = "Drops"
    static let guideTitle = "Drop, then set"
    static let skip = "Skip"
    static let continueTitle = "Continue"
    static let next = "Next"
    static let saved = "Saved."
    static let amount = "Amount"
    static let retry = "Retry"
    static let target = "Target"
    static let openHistory = "History"
    static let wiresTitle = "Quartiles"
    static let intro = "Show intro"
    static let exportFailed = "Export failed. The file was not written."
    static let amountInvalid = "Enter a positive amount."
    static let nameInvalid = "Enter a name."
    static let targetInvalid = "Enter a target above zero."
    static let codeInvalid = "Enter a 3 letter currency code."
    static let seedInvalid = "Enter a whole number for the vine, or leave it blank."
    static let commitWord = "Commit"
    static let refusedWord = "Refused"
    static let ripeWord = "Ripe"
    static let hollowEmptyTitle = "No refused commits."
    static let hollowEmptyBody = "Add a cash drop to the tray, then commit that batch toward your savings goal. A commit is refused only when the tray is empty."
    static let addDrop = "Add a drop"
    static let commitTray = "Commit waiting cash"
    static let peelLast = "Remove last drop"
    static let cancel = "Cancel"
    static let savedNow = "Saved so far"
    static let allActivity = "All"
    static let dayActivity = "Moved this day"
    static let ripeEmptyTitle = "No ripe refusals."
    static let ripeEmptyBody = "A finished goal refuses extra drops."
    static let page1Title = "Cash, by hand."
    static let page1Body = "Name a goal. Drop loose cash. Nothing is linked to a bank."
    static let page2Title = "The vine waits."
    static let page2Body = "A drop does not grow the vine. Set the batch and the height moves."
    static let page3Title = "Payday is the commit."
    static let page3Body = "Unpooled cash stays put until you set it. Peel takes back only the last drop."
    static let guideBody = "Drop fills the waiting cash. Set moves that whole batch into the vine. One tap does not do both."
    static let quickDrops = "Quick amounts"
    static let addAmount = "Add amount"
    static let currency = "Currency"
    static let vineNumber = "Vine number"
    static let active = "Active"
    static let switchGoal = "Switch"
    static let phaseOpen = "Open"
    static let phaseWaiting = "Waiting"
    static let phaseRipe = "Ripe"
    static let lit = "Lit"
    static let dark = "Not yet"
    static let support = "Support"
    static let couldNot = "could not"
    static let tryAgain = "Try again"

    static let inTheTray = "In the tray"
    static let trayEmptyPeel = "The tray has no drop to remove."
    static let keepDrop = "Keep this drop"
    static let waitingToCommit = "Waiting to commit"
    static let pastCommits = "Past commits"

    static func phase(_ phase: CordonPhase) -> String {
        switch phase {
        case .bare: phaseOpen
        case .trayed: phaseWaiting
        case .canopied: phaseRipe
        }
    }

    static func stillInTray(_ name: String) -> String {
        "This cash is still in the tray. Commit moves the whole batch into \(name)."
    }

    static func commitAmount(_ money: String, goal: String) -> String {
        "Commit \(money) to \(goal)"
    }

    static func dropsNotSaved(_ name: String) -> String {
        "These drops are not saved yet. Commit them to \(name), or add another drop."
    }

    static func commitToGoal(_ money: String) -> String {
        "Commit \(money) to goal"
    }

    static func addedOn(_ day: String) -> String {
        "Added \(day)"
    }

    static func removingDrop(_ money: String, goal: String) -> String {
        "Removing this \(money) drop lowers the waiting tray. Cash already committed toward \(goal) stays saved."
    }

    static func removeDrop(_ money: String) -> String {
        "Remove \(money) drop"
    }

    static func dayMoved(_ label: String, money: String) -> String {
        "\(label): \(money)"
    }

    static func goalTarget(_ money: String) -> String {
        "Goal \(money)"
    }

    static func waitingTray(_ money: String) -> String {
        "Waiting in the tray: \(money). Commit that batch, or add another drop."
    }

    static func commitMoney(_ money: String) -> String {
        "Commit \(money)"
    }
}

enum CanopyFormat {
    static func money(_ amount: Decimal, code: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: amount as NSDecimalNumber) ?? zeroMoney(code: code)
    }

    static func plain(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter.string(from: amount as NSDecimalNumber) ?? "0"
    }

    static func dayKey(_ key: Int) -> String {
        let year = key / 10_000
        let month = (key / 100) % 100
        let day = key % 100
        var parts = DateComponents()
        parts.year = year
        parts.month = month
        parts.day = day
        let calendar = Calendar(identifier: .gregorian)
        guard (1...12).contains(month), (1...31).contains(day), let date = calendar.date(from: parts) else {
            return "Unknown day"
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = calendar
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }

    static func percent(_ fraction: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        return formatter.string(from: fraction as NSDecimalNumber) ?? "0%"
    }

    static func seed(_ value: UInt64) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.usesGroupingSeparator = false
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }

    static func parseDecimal(_ text: String) -> Decimal? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = .current
        guard let number = formatter.number(from: trimmed) else { return nil }
        let value = number.decimalValue
        guard value > 0 else { return nil }
        return value
    }

    private static func zeroMoney(code: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        return formatter.string(from: 0) ?? "0"
    }
}

enum CommitHaptic {
    @MainActor
    static func success() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}
