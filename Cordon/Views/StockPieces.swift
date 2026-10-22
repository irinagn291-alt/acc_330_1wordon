import Charts
import SwiftUI

struct StatusBannerRow: View {
    var message: String
    var showsRetry: Bool
    var retry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: CanopyMetrics.steps(1)) {
            Text(message)
                .canopyFont(.body)
                .foregroundStyle(CanopyColor.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
            if showsRetry {
                Button(action: retry) {
                    Text(CanopyCopy.retry)
                }
                .buttonStyle(CanopyButtonStyle(kind: .secondary))
            }
        }
        .padding(CanopyMetrics.steps(2))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: CanopyRadius.card, style: .continuous))
    }
}

struct EmptyStateCard: View {
    var imageName: String
    var title: String
    var line: String
    var actionTitle: String
    var action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: CanopyMetrics.steps(2)) {
            Spacer(minLength: CanopyMetrics.steps(2))
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: CanopyMetrics.art, maxHeight: CanopyMetrics.art)
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)
            Text(title)
                .canopyFont(.display, bold: true)
                .foregroundStyle(CanopyColor.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(line)
                .canopyFont(.body)
                .foregroundStyle(CanopyColor.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer(minLength: CanopyMetrics.steps(2))
            Button(action: action) {
                Text(actionTitle)
            }
            .buttonStyle(CanopyButtonStyle(kind: .primary))
        }
        .padding(CanopyMetrics.steps(3))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(CanopyColor.background.ignoresSafeArea())
    }
}

struct LedgerLineRow: View {
    var title: String
    var detail: String
    var amount: String
    var accentAmount: Bool = false

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: CanopyMetrics.steps(1)) {
            VStack(alignment: .leading, spacing: CanopyMetrics.steps(1)) {
                Text(title)
                    .canopyFont(.body, bold: true)
                    .foregroundStyle(CanopyColor.ink)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text(detail)
                    .canopyFont(.label)
                    .foregroundStyle(CanopyColor.muted)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Text(amount)
                .canopyFont(.body, bold: true)
                .foregroundStyle(accentAmount ? CanopyColor.accent : CanopyColor.ink)
                .lineLimit(1)
                .layoutPriority(1)
        }
        .frame(minHeight: CanopyMetrics.hit)
        .accessibilityElement(children: .combine)
    }
}

struct WireBadge: View {
    var fraction: Decimal
    var lit: Bool

    var body: some View {
        HStack(spacing: CanopyMetrics.steps(1)) {
            Circle()
                .strokeBorder(lit ? CanopyColor.accent : CanopyColor.muted, lineWidth: CanopyMetrics.hairline)
                .background(Circle().fill(lit ? CanopyColor.accent : CanopyColor.background))
                .frame(width: CanopyMetrics.dot, height: CanopyMetrics.dot)
            Text(CanopyFormat.percent(fraction))
                .canopyFont(.label, bold: true)
                .foregroundStyle(lit ? CanopyColor.accent : CanopyColor.muted)
                .lineLimit(1)
            Text(lit ? CanopyCopy.lit : CanopyCopy.dark)
                .canopyFont(.micro)
                .foregroundStyle(CanopyColor.muted)
                .lineLimit(1)
        }
        .padding(.horizontal, CanopyMetrics.steps(1))
        .frame(minHeight: CanopyMetrics.hit)
        .background(CanopyColor.surface, in: RoundedRectangle(cornerRadius: CanopyRadius.chip, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

struct BandPoint: Identifiable {
    var dayKey: Int
    var total: Double
    var id: Int { dayKey }
}

struct CanopyChartCard: View {
    var marks: [SetMark]
    var code: String

    private var points: [BandPoint] {
        let ordered = marks.sorted { $0.dayKey < $1.dayKey }
        return ordered.map { mark in
            BandPoint(
                dayKey: mark.dayKey,
                total: NSDecimalNumber(decimal: mark.canopyTotalAfter).doubleValue
            )
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: CanopyMetrics.steps(1)) {
            Text(CanopyCopy.commits)
                .canopyFont(.label, bold: true)
                .foregroundStyle(CanopyColor.muted)
            if points.isEmpty {
                Text("No commits yet. Drop cash, then commit the waiting batch.")
                    .canopyFont(.body)
                    .foregroundStyle(CanopyColor.ink)
                    .frame(maxWidth: .infinity, minHeight: CanopyMetrics.chartHeight, alignment: .leading)
            } else {
                Chart(points) { point in
                    BarMark(
                        x: .value("Day", CanopyFormat.dayKey(point.dayKey).replacingOccurrences(of: ", ", with: "\n")),
                        y: .value("Saved", point.total)
                    )
                    .foregroundStyle(CanopyColor.accent)
                    .cornerRadius(4)
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel(orientation: .vertical) {
                            if let day = value.as(String.self) {
                                Text(day)
                                    .canopyFont(.label)
                                    .foregroundStyle(CanopyColor.ink)
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine().foregroundStyle(CanopyColor.hairline)
                        AxisValueLabel {
                            if let amount = value.as(Double.self) {
                                Text(CanopyFormat.plain(Decimal(amount)))
                                    .canopyFont(.label)
                                    .foregroundStyle(CanopyColor.ink)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: CanopyMetrics.chartHeight)
                .accessibilityLabel(CanopyCopy.history)
            }
            if let last = marks.max(by: { $0.dayKey < $1.dayKey }) {
                LedgerLineRow(
                    title: CanopyCopy.savedNow,
                    detail: CanopyFormat.dayKey(last.dayKey),
                    amount: CanopyFormat.money(last.canopyTotalAfter, code: code),
                    accentAmount: true
                )
            }
        }
        .padding(CanopyMetrics.steps(2))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: CanopyRadius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: CanopyRadius.card, style: .continuous)
                .stroke(CanopyColor.hairline, lineWidth: CanopyMetrics.hairline)
        }
    }
}

struct CoverPageCard<Content: View>: View {
    var title: String
    var showsClose: Bool
    var onClose: () -> Void
    @ViewBuilder var content: () -> Content

    var body: some View {
        NavigationStack {
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(CanopyColor.background.ignoresSafeArea())
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    if showsClose {
                        ToolbarItem(placement: .cancellationAction) {
                            Button(CanopyCopy.close, action: onClose)
                                .frame(minWidth: CanopyMetrics.hit, minHeight: CanopyMetrics.hit)
                        }
                    }
                }
                .toolbarBackground(.regularMaterial, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

struct ExportShareCard: UIViewControllerRepresentable {
    var url: URL

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {
        guard let pop = controller.popoverPresentationController else { return }
        pop.sourceView = controller.view
        let bounds = controller.view.bounds
        pop.sourceRect = CGRect(x: bounds.midX, y: bounds.midY, width: 1, height: 1)
        pop.permittedArrowDirections = []
    }
}
