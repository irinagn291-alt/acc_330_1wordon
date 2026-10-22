import Foundation

/// One hand deposit waiting in the tray. Unsettled drops never move canopy height.
struct DropMark: Codable, Equatable, Identifiable, Sendable {
    var id: UUID
    var goalID: UUID
    var amount: Decimal
    var dayKey: Int
    /// True after a set commits this drop into canopy height.
    var settled: Bool

    init(
        id: UUID = UUID(),
        goalID: UUID,
        amount: Decimal,
        dayKey: Int,
        settled: Bool = false
    ) {
        self.id = id
        self.goalID = goalID
        self.amount = amount
        self.dayKey = dayKey
        self.settled = settled
    }
}
