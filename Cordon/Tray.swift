import Foundation

/// Uncommitted hand deposits. Setting the canopy empties this balance.
struct TrayBalance: Equatable, Sendable {
    var amount: Decimal

    static let zero = TrayBalance(amount: 0)

    var isEmpty: Bool { amount <= 0 }
}
