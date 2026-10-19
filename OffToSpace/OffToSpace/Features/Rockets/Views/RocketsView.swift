import SwiftUI

struct RocketsView: View {
    var body: some View {
        Text("rockets.rockets.placeholder")
            .font(DesignSystem.Fonts.body)
            .foregroundStyle(DesignSystem.Colors.secondaryText)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DesignSystem.Colors.background)
            .navigationTitle("rockets.rockets.title")
            .accessibilityIdentifier("rockets.placeholder")
    }
}

#Preview {
    NavigationStack {
        RocketsView()
    }
}
