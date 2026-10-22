import Foundation

/// A payday commit. The tray sum moved into canopy height on `dayKey`.
struct SetMark: Codable, Equatable, Identifiable, Sendable {
    var id: UUID
    var goalID: UUID
    var amount: Decimal
    var dayKey: Int
    var canopyTotalAfter: Decimal
    var wiresCrossed: [CanopyWire]

    init(
        id: UUID = UUID(),
        goalID: UUID,
        amount: Decimal,
        dayKey: Int,
        canopyTotalAfter: Decimal,
        wiresCrossed: [CanopyWire]
    ) {
        self.id = id
        self.goalID = goalID
        self.amount = amount
        self.dayKey = dayKey
        self.canopyTotalAfter = canopyTotalAfter
        self.wiresCrossed = wiresCrossed
    }
}
