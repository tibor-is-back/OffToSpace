protocol RocketsInteractor {
    var hasNextPage: Bool { get }
    func loadNextPage() async throws -> [Rocket]
}
