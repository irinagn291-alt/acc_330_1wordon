import Foundation

/// Committed canopy height for one goal. Sum of set marks only.
struct CanopyTotal: Equatable, Sendable {
    var amount: Decimal

    static let zero = CanopyTotal(amount: 0)

    static func progress(canopy: Decimal, target: Decimal) -> Decimal {
        guard target > 0 else { return 0 }
        let ratio = canopy / target
        if ratio < 0 { return 0 }
        return ratio
    }
}
