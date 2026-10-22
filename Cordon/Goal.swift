import Foundation

/// Named savings goal staked on one cordon. The vine shape is a pure
/// function of `vineSeed`. Cash never arrives from a bank feed.
struct CordonGoal: Codable, Equatable, Identifiable, Sendable {
    var id: UUID
    var name: String
    var targetAmount: Decimal
    var currencyCode: String
    var vineSeed: UInt64
    var plantedDayKey: Int

    init(
        id: UUID = UUID(),
        name: String,
        targetAmount: Decimal,
        currencyCode: String = "USD",
        vineSeed: UInt64,
        plantedDayKey: Int
    ) {
        self.id = id
        self.name = name
        self.targetAmount = targetAmount
        self.currencyCode = currencyCode
        self.vineSeed = vineSeed
        self.plantedDayKey = plantedDayKey
    }
}

/// Branch lean derived from the goal seed. Same seed, same silhouette.
struct VineShape: Equatable, Sendable {
    var lean: Double
    var forks: Int
    var twist: Double

    static func from(seed: UInt64) -> VineShape {
        var state = seed == 0 ? 0xC0D0_0001 : seed
        state = mix(state)
        let leanUnit = Double(state % 10_000) / 10_000
        state = mix(state)
        let forks = Int(state % 4) + 1
        state = mix(state)
        let twist = Double(state % 10_000) / 10_000
        return VineShape(lean: (leanUnit * 2) - 1, forks: forks, twist: twist)
    }

    private static func mix(_ value: UInt64) -> UInt64 {
        var mixed = value &* 0x9E37_79B9_7F4A_7C15
        mixed ^= mixed >> 30
        mixed &*= 0xBF58_476D_1CE4_E5B9
        mixed ^= mixed >> 27
        return mixed
    }
}
