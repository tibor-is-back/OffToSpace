import Foundation

final class DefaultLaunchesInteractor {
    private let repository: any LaunchesRepository
    private var pagination: PageHandler
    private var filter: LaunchFilter

    init(repository: any LaunchesRepository,
         filter: LaunchFilter,
         pageSize: Int = 20) {
        self.repository = repository
        self.filter = filter
        self.pagination = PageHandler(limit: pageSize)
    }
}

extension DefaultLaunchesInteractor: LaunchesInteractor {
    var hasNextPage: Bool {
        pagination.nextPage != nil
    }

    func updateFilter(_ filter: LaunchFilter) {
        self.filter = filter
        pagination.reset()
    }

    func loadNextPage() async throws -> [Launch] {
        guard let page = pagination.nextPage else {
            return []
        }

        let result = try await repository.fetchLaunches(page: page,
                                                        limit: pagination.limit,
                                                        startDate: filter.startDate,
                                                        endDate: filter.endDate)

        try Task.checkCancellation()

        pagination.advance(page: result.page, hasNextPage: result.hasNextPage)

        return result.items
    }
}
