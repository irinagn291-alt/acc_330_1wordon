import SwiftUI

@main
struct CordonWatchApp: App {
    var body: some Scene {
        WindowGroup {
            WatchRoot()
        }
    }
}

/// Watch cover. Same today / log / goals keys as the phone, from the demo fold.
struct WatchRoot: View {
    private let ledger = CordonDemo.archive().ledger
    private var canvas: CordonCanvasState {
        CordonPresenter.present(ledger: ledger)
    }

    var body: some View {
        switch ReviewLaunch.screen {
        case "log":
            log
        case "goals":
            goals
        default:
            today
        }
    }

    private var today: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(canvas.goalName)
                .font(.custom(DesignTokens.fontFamily, size: 12))
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(1)
            Text(money(canvas.canopyTotal))
                .font(.custom(DesignTokens.fontFamily, size: 22).weight(.bold))
                .foregroundStyle(DesignTokens.accent)
                .lineLimit(1)
            Text(money(canvas.tray))
                .font(.custom(DesignTokens.fontFamily, size: 14))
                .foregroundStyle(DesignTokens.muted)
            Text(setTitle)
                .font(.custom(DesignTokens.fontFamily, size: 13).weight(.bold))
                .foregroundStyle(DesignTokens.bg)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(canvas.setCanopyEnabled ? DesignTokens.accent : DesignTokens.surface, in: Capsule())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(8)
        .background(DesignTokens.bg)
    }

    private var log: some View {
        List(ledger.setMarks) { mark in
            VStack(alignment: .leading) {
                Text(day(mark.dayKey))
                    .font(.custom(DesignTokens.fontFamily, size: 12))
                Text(money(mark.amount))
                    .font(.custom(DesignTokens.fontFamily, size: 14).weight(.bold))
            }
        }
    }

    private var goals: some View {
        List(ledger.goals) { goal in
            VStack(alignment: .leading) {
                Text(goal.name)
                    .font(.custom(DesignTokens.fontFamily, size: 13).weight(.bold))
                    .lineLimit(1)
                Text(money(goal.targetAmount, code: goal.currencyCode))
                    .font(.custom(DesignTokens.fontFamily, size: 12))
            }
        }
    }

    private var setTitle: String { "Set Canopy" }

    private func money(_ amount: Decimal, code: String = "USD") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSDecimalNumber) ?? "0"
    }

    private func day(_ key: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.usesGroupingSeparator = false
        return formatter.string(from: NSNumber(value: key)) ?? "0"
    }
}
