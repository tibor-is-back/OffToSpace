import Foundation

final class DefaultRocketsInteractor {
    private let repository: any RocketsRepository
    private var pagination: PageHandler

    init(repository: any RocketsRepository,
         pageSize: Int = 20) {
        self.repository = repository
        self.pagination = PageHandler(limit: pageSize)
    }
}

extension DefaultRocketsInteractor: RocketsInteractor {
    func loadRocket(id: String) async throws -> Rocket {
        try await repository.fetchRocket(id: id)
    }

    var hasNextPage: Bool {
        pagination.nextPage != nil
    }

    func loadNextPage() async throws -> [Rocket] {
        guard let page = pagination.nextPage else {
            return []
        }

        let result = try await repository.fetchRockets(page: page,
                                                       limit: pagination.limit)

        try Task.checkCancellation()

        pagination.advance(page: result.page, hasNextPage: result.hasNextPage)

        return result.items
    }
}
