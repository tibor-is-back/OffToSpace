protocol RocketsInteractor {
    var hasNextPage: Bool { get }
    func loadNextPage() async throws -> [Rocket]
    func loadRocket(id: String) async throws -> Rocket
}
