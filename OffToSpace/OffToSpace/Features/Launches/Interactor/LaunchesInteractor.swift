protocol LaunchesInteractor {
    var hasNextPage: Bool { get }
    func updateFilter(_ filter: LaunchFilter)
    func loadNextPage() async throws -> [Launch]
}
