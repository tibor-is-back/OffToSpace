import Foundation

final class DefaultRocketsInteractor {
    private var cache: [String: Rocket] = [:]
    private let repository: any RocketsRepository
    private var pagination: PageHandler

    init(repository: any RocketsRepository,
         pageSize: Int = 10) {
        self.repository = repository
        self.pagination = PageHandler(limit: pageSize)
    }
}

extension DefaultRocketsInteractor: RocketsInteractor {
    func loadRocket(id: String) async throws -> Rocket {
        try Task.checkCancellation()
        if let rocket = cache[id] {
            return rocket
        }
        let rocket = try await repository.fetchRocket(id: id)
        try Task.checkCancellation()
        cache[id] = rocket
        return rocket
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

        for item in result.items {
            cache[item.id] = item
        }
        pagination.advance(page: result.page, hasNextPage: result.hasNextPage)

        return result.items
    }
}
