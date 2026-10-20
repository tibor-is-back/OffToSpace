import SwiftUI

struct LaunchesDatePicker: View {
    private let startDate: Date
    private let endDate: Date
    private let onDone: (Date, Date) -> Void
    @State private var isPresented = false

    private static let dateFormat = Date.FormatStyle().month(.abbreviated).day().year()

    init(startDate: Date? = nil, endDate: Date? = nil, onDone: @escaping (Date, Date) -> Void) {
        let calendar = Calendar.current
        guard let year = calendar.dateInterval(of: .year, for: .now),
              let yearEnd = calendar.date(byAdding: .second, value: -1, to: year.end) else {
            preconditionFailure("The current calendar must provide the current year's date range.")
        }
        self.startDate = startDate ?? year.start
        self.endDate = endDate ?? yearEnd
        self.onDone = onDone
    }

    var body: some View {
        Button {
            isPresented = true
        } label: {
            HStack(spacing: DesignSystem.Spacing.medium) {
                Image(systemName: "calendar")
                    .accessibilityHidden(true)

                Text("launches.datePicker.range \(startDate.formatted(Self.dateFormat)) \(endDate.formatted(Self.dateFormat))")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)

                Image(systemName: "chevron.right")
                    .foregroundStyle(DesignSystem.Colors.tertiaryText)
                    .accessibilityHidden(true)
            }
            .font(DesignSystem.Fonts.body)
            .foregroundStyle(DesignSystem.Colors.primaryText)
            .padding(DesignSystem.Spacing.medium)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
            .overlay {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .stroke(DesignSystem.Colors.separator, lineWidth: DesignSystem.BorderWidth.thin)
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("launches.dateRange")
        .accessibilityHint("launches.datePicker.hint")
        .sheet(isPresented: $isPresented) {
            LaunchesDateRangeSheet(startDate: startDate, endDate: endDate, onDone: onDone)
        }
    }
}

#Preview("Light") {
    LaunchesDatePicker(
        startDate: LaunchesPreviewData.rangeStart,
        endDate: LaunchesPreviewData.rangeEnd,
        onDone: { _, _ in }
    )
        .padding(DesignSystem.Spacing.medium)
        .background(Image("LaunchesHeader").resizable().scaledToFill())
}

#Preview("Dark") {
    LaunchesDatePicker(
        startDate: LaunchesPreviewData.rangeStart,
        endDate: LaunchesPreviewData.rangeEnd,
        onDone: { _, _ in }
    )
        .padding(DesignSystem.Spacing.medium)
        .background(Image("LaunchesHeader").resizable().scaledToFill())
        .preferredColorScheme(.dark)
}
