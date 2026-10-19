import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Fonts.body.weight(.semibold))
            .foregroundStyle(DesignSystem.Colors.onAccent)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, DesignSystem.Spacing.medium)
            .padding(.vertical, DesignSystem.Spacing.medium)
            .background(DesignSystem.Colors.accent)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
            .opacity(opacity(isPressed: configuration.isPressed))
    }

    private func opacity(isPressed: Bool) -> Double {
        guard isEnabled else {
            return DesignSystem.Opacity.disabled
        }
        return isPressed ? DesignSystem.Opacity.pressedFilled : DesignSystem.Opacity.full
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

#Preview("Primary Button") {
    Button("Primary") {}
        .buttonStyle(.primary)
        .padding(.horizontal, DesignSystem.Spacing.medium)
        .frame(maxWidth: .infinity)
}

#Preview("Primary Button – Dark") {
    Button("Primary") {}
        .buttonStyle(.primary)
        .padding(.horizontal, DesignSystem.Spacing.medium)
        .frame(maxWidth: .infinity)
        .preferredColorScheme(.dark)
}

#Preview("Primary Button – Disabled") {
    Button("Primary") {}
        .buttonStyle(.primary)
        .disabled(true)
        .padding(.horizontal, DesignSystem.Spacing.medium)
        .frame(maxWidth: .infinity)
}
