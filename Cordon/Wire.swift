import Foundation

/// Quartile wires on the cordon. Progress is committed canopy over target.
enum CanopyWire: String, Codable, CaseIterable, Equatable, Sendable {
    case quarter = "0.25"
    case half = "0.50"
    case threeQuarter = "0.75"
    case ripe = "1.00"

    var threshold: Decimal {
        switch self {
        case .quarter: 0.25
        case .half: 0.50
        case .threeQuarter: 0.75
        case .ripe: 1
        }
    }

    /// Wires the commit crosses. Tray cash is not part of progress.
    static func crossed(before: Decimal, after: Decimal) -> [CanopyWire] {
        allCases.filter { wire in
            before < wire.threshold && after >= wire.threshold
        }
    }
}

enum DayKey {
    static func make(from date: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: date)
        let parts = calendar.dateComponents([.year, .month, .day], from: start)
        let year = parts.year ?? 0
        let month = parts.month ?? 0
        let day = parts.day ?? 0
        return (year * 10_000) + (month * 100) + day
    }
}
