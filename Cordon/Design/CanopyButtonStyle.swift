import SwiftUI

/// Filled capsule for the live verb. Pressed and disabled states are visible.
struct CanopyButtonStyle: ButtonStyle {
    enum Kind {
        case primary
        case secondary
        case destructive
    }

    var kind: Kind = .primary
    var fills: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        CanopyButtonBody(configuration: configuration, kind: kind, fills: fills)
    }
}

private struct CanopyButtonBody: View {
    let configuration: ButtonStyleConfiguration
    var kind: CanopyButtonStyle.Kind
    var fills: Bool

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        configuration.label
            .canopyFont(.body, bold: true)
            .foregroundStyle(foreground)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .frame(maxWidth: fills ? .infinity : nil, minHeight: CanopyMetrics.hit)
            .padding(.horizontal, CanopyMetrics.steps(2))
            .padding(.vertical, CanopyMetrics.steps(1))
            .background(background, in: Capsule())
            .contentShape(Capsule())
            .scaleEffect(configuration.isPressed && isEnabled ? CanopyMotion.pressScale : 1)
            .opacity(configuration.isPressed && isEnabled ? 0.82 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }

    private var foreground: Color {
        switch kind {
        case .primary:
            return isEnabled ? CanopyColor.background : CanopyColor.muted
        case .secondary, .destructive:
            return isEnabled ? CanopyColor.ink : CanopyColor.muted
        }
    }

    private var background: Color {
        guard isEnabled else { return CanopyColor.surface }
        switch kind {
        case .primary:
            return CanopyColor.accent
        case .secondary:
            return CanopyColor.ink.opacity(0.16)
        case .destructive:
            return CanopyColor.surface
        }
    }
}

struct CanopyRowStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
            .opacity(configuration.isPressed ? 0.72 : 1)
            .scaleEffect(configuration.isPressed ? CanopyMotion.pressScale : 1)
    }
}

struct CanopyChipStyle: ButtonStyle {
    var selected: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .canopyFont(.label, bold: true)
            .foregroundStyle(selected ? CanopyColor.background : CanopyColor.ink)
            .lineLimit(1)
            .padding(.horizontal, CanopyMetrics.steps(2))
            .frame(minHeight: CanopyMetrics.hit)
            .background(
                selected ? CanopyColor.accent : CanopyColor.surface,
                in: RoundedRectangle(cornerRadius: CanopyRadius.chip, style: .continuous)
            )
            .contentShape(RoundedRectangle(cornerRadius: CanopyRadius.chip, style: .continuous))
            .scaleEffect(configuration.isPressed ? CanopyMotion.pressScale : 1)
            .opacity(configuration.isPressed ? 0.82 : 1)
    }
}
