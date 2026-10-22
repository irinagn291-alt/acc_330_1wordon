import Foundation

/// One root record. Goals, marks, and the active cordon share a single document.
struct CordonArchive: Codable, Equatable, Sendable {
    static let currentSchema = 1
    static let defaultsKey = "cdn.cordon.archive.v1"
    static let demoKey = "cdn.demo.v1"

    var schemaVersion: Int
    var ledger: CordonLedger

    init(schemaVersion: Int = CordonArchive.currentSchema, ledger: CordonLedger) {
        self.schemaVersion = schemaVersion
        self.ledger = ledger
    }

    enum CodingKeys: String, CodingKey {
        case schemaVersion
        case goals
        case setMarks
        case dropMarks
        case hollowMarks
        case ripeMarks
        case activeGoalID
        case onboardingComplete
        case quickDropAmounts
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let version = try container.decode(Int.self, forKey: .schemaVersion)
        switch version {
        case 1:
            schemaVersion = version
            ledger = CordonLedger(
                goals: try container.decode([CordonGoal].self, forKey: .goals),
                setMarks: try container.decode([SetMark].self, forKey: .setMarks),
                dropMarks: try container.decode([DropMark].self, forKey: .dropMarks),
                hollowMarks: try container.decode([HollowMark].self, forKey: .hollowMarks),
                ripeMarks: try container.decode([RipeMark].self, forKey: .ripeMarks),
                activeGoalID: try container.decodeIfPresent(UUID.self, forKey: .activeGoalID),
                onboardingComplete: try container.decodeIfPresent(Bool.self, forKey: .onboardingComplete) ?? false,
                quickDropAmounts: try container.decodeIfPresent([Decimal].self, forKey: .quickDropAmounts)
                    ?? CordonLedger.empty.quickDropAmounts
            )
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .schemaVersion,
                in: container,
                debugDescription: "Unknown cordon schema \(version)"
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(schemaVersion, forKey: .schemaVersion)
        try container.encode(ledger.goals, forKey: .goals)
        try container.encode(ledger.setMarks, forKey: .setMarks)
        try container.encode(ledger.dropMarks, forKey: .dropMarks)
        try container.encode(ledger.hollowMarks, forKey: .hollowMarks)
        try container.encode(ledger.ripeMarks, forKey: .ripeMarks)
        try container.encodeIfPresent(ledger.activeGoalID, forKey: .activeGoalID)
        try container.encode(ledger.onboardingComplete, forKey: .onboardingComplete)
        try container.encode(ledger.quickDropAmounts, forKey: .quickDropAmounts)
    }

    static func encodeData(_ archive: CordonArchive) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        encoder.nonConformingFloatEncodingStrategy = .throw
        return try encoder.encode(archive)
    }

    static func decodeData(_ data: Data) throws -> CordonArchive {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        return try decoder.decode(CordonArchive.self, from: data)
    }
}

enum CordonLoadStatus: Equatable, Sendable {
    case ready
    case recoveredFromBackup
    case startedEmpty(String)
}

struct CordonLoad: Sendable {
    var archive: CordonArchive
    var status: CordonLoadStatus
}
