import SwiftUI

/// Home action strip. Drop fills the tray. Set commits it. Peel removes the last drop.
struct FusedActionStripCard: View {
    @Binding var amountText: String
    @FocusState.Binding var focused: Bool
    var quickAmounts: [Decimal]
    var code: String
    var setEnabled: Bool
    var peelEnabled: Bool
    var dropEnabled: Bool
    var locked: Bool
    var onQuick: (Decimal) -> Void
    var onDrop: () -> Void
    var onPeel: () -> Void
    var onSet: () -> Void

    private var parsed: Decimal? { CanopyFormat.parseDecimal(amountText) }
    private var showsInvalid: Bool {
        !amountText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && parsed == nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: CanopyMetrics.steps(1)) {
            Text(CanopyCopy.amount)
                .canopyFont(.label, bold: true)
                .foregroundStyle(CanopyColor.muted)
            TextField(CanopyCopy.amount, text: $amountText)
                .canopyFont(.display, bold: true)
                .foregroundStyle(CanopyColor.ink)
                .keyboardType(.decimalPad)
                .focused($focused)
                .id("amount-field")
                .frame(minHeight: CanopyMetrics.hit)
            if showsInvalid {
                Text(CanopyCopy.amountInvalid)
                    .canopyFont(.label)
                    .foregroundStyle(CanopyColor.ink)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CanopyMetrics.steps(1)) {
                    ForEach(quickAmounts, id: \.self) { amount in
                        Button {
                            onQuick(amount)
                        } label: {
                            Text(CanopyFormat.money(amount, code: code))
                                .lineLimit(1)
                        }
                        .buttonStyle(CanopyChipStyle())
                        .disabled(locked)
                    }
                }
            }
            HStack(spacing: CanopyMetrics.steps(1)) {
                Button(action: onPeel) {
                    Label(CanopyCopy.peel, systemImage: "arrow.uturn.backward")
                        .frame(maxWidth: .infinity, minHeight: CanopyMetrics.hit)
                        .contentShape(Capsule())
                }
                .buttonStyle(CanopyButtonStyle(kind: .secondary))
                .disabled(!peelEnabled || locked)
                Button(action: onDrop) {
                    Label(CanopyCopy.drop, systemImage: "plus")
                        .frame(maxWidth: .infinity, minHeight: CanopyMetrics.hit)
                        .contentShape(Capsule())
                }
                .buttonStyle(CanopyButtonStyle(kind: .secondary))
                .disabled(!dropEnabled || locked || parsed == nil)
            }
            Button(action: onSet) {
                Text(CanopyCopy.setCanopy)
            }
            .buttonStyle(CanopyButtonStyle(kind: .primary))
            .disabled(!setEnabled || locked)
            .accessibilityHint(CanopyCopy.nextTap)
        }
        .padding(CanopyMetrics.steps(2))
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: CanopyRadius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: CanopyRadius.card, style: .continuous)
                .stroke(CanopyColor.hairline, lineWidth: CanopyMetrics.hairline)
        }
    }
}
