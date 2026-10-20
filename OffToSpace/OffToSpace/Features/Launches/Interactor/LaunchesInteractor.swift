protocol LaunchesInteractor {
    var hasNextPage: Bool { get }
    func updateFilter(_ filter: LaunchFilter)
    func loadNextPage() async throws -> [Launch]
    func loadLaunch(id: String) throws -> Launch
}

enum LaunchDetailsError: Error {
    case notFound
}
