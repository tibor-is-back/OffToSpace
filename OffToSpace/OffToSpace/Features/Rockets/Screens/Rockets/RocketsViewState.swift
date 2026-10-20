enum RocketsViewState {
    case loading
    case loaded([RocketsListItemViewData], pagination: Pagination = .idle)
    case empty
    case error

    enum Pagination {
        case idle
        case loading
        case error
        case finished
    }
}
