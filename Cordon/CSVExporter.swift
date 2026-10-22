import Foundation

/// Plain-text ledger of set marks and drop marks for the settings export.
enum CSVExporter {
    static func text(ledger: CordonLedger) -> String {
        var lines = ["kind,id,goalID,amount,dayKey,settled,wires"]
        for mark in ledger.setMarks {
            let wires = mark.wiresCrossed.map(\.rawValue).joined(separator: "|")
            lines.append(row(
                kind: "set",
                id: mark.id,
                goalID: mark.goalID.uuidString,
                amount: mark.amount,
                dayKey: mark.dayKey,
                settled: "",
                wires: wires
            ))
        }
        for mark in ledger.dropMarks {
            lines.append(row(
                kind: "drop",
                id: mark.id,
                goalID: mark.goalID.uuidString,
                amount: mark.amount,
                dayKey: mark.dayKey,
                settled: mark.settled ? "yes" : "no",
                wires: ""
            ))
        }
        for mark in ledger.hollowMarks {
            lines.append(row(
                kind: "hollow",
                id: mark.id,
                goalID: mark.goalID?.uuidString ?? "",
                amount: 0,
                dayKey: mark.dayKey,
                settled: "",
                wires: ""
            ))
        }
        for mark in ledger.ripeMarks {
            lines.append(row(
                kind: "ripe",
                id: mark.id,
                goalID: mark.goalID.uuidString,
                amount: mark.amount,
                dayKey: mark.dayKey,
                settled: "",
                wires: ""
            ))
        }
        return lines.joined(separator: "\n")
    }

    static func writeFile(ledger: CordonLedger, directory: URL) throws -> URL {
        let folder = directory
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let url = folder.appendingPathComponent("cordon-ledger.csv")
        let data = Data(text(ledger: ledger).utf8)
        let temporary = folder.appendingPathComponent("cordon-ledger-\(UUID().uuidString).tmp")
        try data.write(to: temporary, options: .atomic)
        if FileManager.default.fileExists(atPath: url.path) {
            _ = try FileManager.default.replaceItemAt(url, withItemAt: temporary)
        } else {
            try FileManager.default.moveItem(at: temporary, to: url)
        }
        return url
    }

    private static func row(
        kind: String,
        id: UUID,
        goalID: String,
        amount: Decimal,
        dayKey: Int,
        settled: String,
        wires: String
    ) -> String {
        "\(kind),\(id.uuidString),\(goalID),\(decimal(amount)),\(dayKey),\(settled),\(wires)"
    }

    private static func decimal(_ value: Decimal) -> String {
        NSDecimalNumber(decimal: value).stringValue
    }
}
