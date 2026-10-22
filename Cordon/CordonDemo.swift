import Foundation

/// Simulator seed. Two open drops sit in the tray so the first tap can set the canopy.
enum CordonDemo {
    static func archive(dayKey: Int = 20261018) -> CordonArchive {
        let rainy = CordonGoal(
            id: UUID(uuidString: "A1000000-0000-0000-0000-000000000001") ?? UUID(),
            name: "Rainy week",
            targetAmount: 400,
            vineSeed: 0xC0D0_11A1,
            plantedDayKey: 20260901
        )
        let rent = CordonGoal(
            id: UUID(uuidString: "A1000000-0000-0000-0000-000000000002") ?? UUID(),
            name: "Rent buffer",
            targetAmount: 1200,
            vineSeed: 0xC0D0_22B2,
            plantedDayKey: 20260812
        )
        let trip = CordonGoal(
            id: UUID(uuidString: "A1000000-0000-0000-0000-000000000003") ?? UUID(),
            name: "Train fare",
            targetAmount: 180,
            vineSeed: 0xC0D0_33C3,
            plantedDayKey: 20261001
        )
        let bike = CordonGoal(
            id: UUID(uuidString: "A1000000-0000-0000-0000-000000000004") ?? UUID(),
            name: "Bike lock",
            targetAmount: 80,
            vineSeed: 0xC0D0_44D4,
            plantedDayKey: 20260704
        )
        var ledger = CordonLedger.empty
        ledger.plant(rainy)
        ledger.plant(rent, makeActive: false)
        ledger.plant(trip, makeActive: false)
        ledger.plant(bike, makeActive: false)
        ledger.activeGoalID = rainy.id
        ledger.onboardingComplete = true
        _ = ledger.drop(amount: 40, dayKey: 20260920, goalID: rainy.id)
        _ = ledger.setCanopy(dayKey: 20260920, goalID: rainy.id)
        _ = ledger.drop(amount: 60, dayKey: 20261002, goalID: rainy.id)
        _ = ledger.setCanopy(dayKey: 20261002, goalID: rainy.id)
        _ = ledger.drop(amount: 25, dayKey: dayKey, goalID: rainy.id)
        _ = ledger.drop(amount: 15, dayKey: dayKey, goalID: rainy.id)
        _ = ledger.drop(amount: 200, dayKey: 20260901, goalID: rent.id)
        _ = ledger.setCanopy(dayKey: 20260901, goalID: rent.id)
        _ = ledger.drop(amount: 150, dayKey: 20261008, goalID: rent.id)
        _ = ledger.setCanopy(dayKey: 20261008, goalID: rent.id)
        _ = ledger.drop(amount: 80, dayKey: 20260801, goalID: bike.id)
        _ = ledger.setCanopy(dayKey: 20260801, goalID: bike.id)
        return CordonArchive(ledger: ledger)
    }
}
