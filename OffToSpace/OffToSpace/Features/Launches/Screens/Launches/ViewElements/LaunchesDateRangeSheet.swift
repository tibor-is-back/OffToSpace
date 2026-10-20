import SwiftUI

struct LaunchesDateRangeSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var startDate: Date
    @State private var endDate: Date
    private let onDone: (Date, Date) -> Void

    init(startDate: Date, endDate: Date, onDone: @escaping (Date, Date) -> Void) {
        _startDate = State(initialValue: startDate)
        _endDate = State(initialValue: endDate)
        self.onDone = onDone
    }

    var body: some View {
        NavigationStack {
            Form {
                DatePicker(
                    "launches.datePicker.startDate",
                    selection: $startDate,
                    in: ...endDate,
                    displayedComponents: .date
                )
                .accessibilityIdentifier("launches.startDate")

                DatePicker(
                    "launches.datePicker.endDate",
                    selection: $endDate,
                    in: startDate...,
                    displayedComponents: .date
                )
                .accessibilityIdentifier("launches.endDate")
            }
            .navigationTitle("launches.datePicker.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("launches.datePicker.done") {
                        onDone(startDate, endDate)
                        dismiss()
                    }
                    .accessibilityIdentifier("launches.datePickerDone")
                }
            }
        }
        .tint(DesignSystem.Colors.accent)
        .presentationDetents(
            dynamicTypeSize.isAccessibilitySize
                ? [.large]
                : [.height(DesignSystem.Size.dateRangeSheetHeight), .large]
        )
    }
}

#Preview("Light") {
    LaunchesDateRangeSheet(
        startDate: LaunchesPreviewData.rangeStart,
        endDate: LaunchesPreviewData.rangeEnd,
        onDone: { _, _ in }
    )
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    LaunchesDateRangeSheet(
        startDate: LaunchesPreviewData.rangeStart,
        endDate: LaunchesPreviewData.rangeEnd,
        onDone: { _, _ in }
    )
    .preferredColorScheme(.dark)
}
