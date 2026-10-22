import Foundation

/// Refused set. Written when set runs on a bare cordon or an empty tray.
struct HollowMark: Codable, Equatable, Identifiable, Sendable {
    var id: UUID
    var goalID: UUID?
    var dayKey: Int

    init(id: UUID = UUID(), goalID: UUID?, dayKey: Int) {
        self.id = id
        self.goalID = goalID
        self.dayKey = dayKey
    }
}
