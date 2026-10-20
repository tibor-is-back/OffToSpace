import Foundation

enum LaunchesViewEvent {
    case appeared
    case nextPageRequested
    case retryTapped
    case dateRangeSelected(startDate: Date, endDate: Date)
}
