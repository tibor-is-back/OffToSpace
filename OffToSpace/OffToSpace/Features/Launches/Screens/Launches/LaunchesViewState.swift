struct LaunchesViewState {
    var filter: LaunchFilter
    var content: Content = .loading

    enum Content {
        case loading
        case loaded([LaunchesListItemViewData], pagination: Pagination = .idle)
        case empty
        case error
    }

    enum Pagination: Hashable {
        case idle
        case loading
        case error
        case finished
    }
}
