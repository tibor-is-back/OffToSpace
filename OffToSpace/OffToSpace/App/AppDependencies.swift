import Foundation

struct AppDependencies {
    let launches: Launches
    private let apiClient: any APIClient

    init() {
        let apiClient = DefaultAPIClient()
        self.apiClient = apiClient
        guard let baseURL = URL(string: "http://localhost:3000") else {
            preconditionFailure("The configured SpaceX API URL must be valid.")
        }
        launches = Launches(apiClient: apiClient, baseURL: baseURL)
    }

    struct Launches {
        private let repository: any LaunchesRepository

        init(apiClient: any APIClient, baseURL: URL) {
            repository = DefaultLaunchesRepository(apiClient: apiClient, baseURL: baseURL)
        }

        func makeViewModel() -> LaunchesViewModel {
            let calendar = Calendar.current
            guard let year = calendar.dateInterval(of: .year, for: .now),
                  let yearEnd = calendar.date(byAdding: .second, value: -1, to: year.end) else {
                preconditionFailure("The current calendar must provide the current year's date range.")
            }
            let filter = LaunchFilter(startDate: year.start, endDate: yearEnd)
            return LaunchesViewModel(
                interactor: DefaultLaunchesInteractor(repository: repository, filter: filter),
                filter: filter
            )
        }
    }
}
