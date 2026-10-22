import Foundation

/// Refused drop. Written when cash is dropped onto a cordon that is already ripe.
struct RipeMark: Codable, Equatable, Identifiable, Sendable {
    var id: UUID
    var goalID: UUID
    var amount: Decimal
    var dayKey: Int

    init(id: UUID = UUID(), goalID: UUID, amount: Decimal, dayKey: Int) {
        self.id = id
        self.goalID = goalID
        self.amount = amount
        self.dayKey = dayKey
    }
}
