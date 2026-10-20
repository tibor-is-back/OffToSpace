import Foundation

struct AppDependencies {
    let launches: Launches
    let rockets: Rockets
    private let apiClient: any APIClient

    init(isUITesting: Bool = AppEnvironment.isUITesting) {
        let apiClient = DefaultAPIClient()
        self.apiClient = apiClient
        guard let baseURL = URL(string: "http://localhost:3000") else {
            preconditionFailure("The configured SpaceX API URL must be valid.")
        }
        launches = Launches(apiClient: apiClient, baseURL: baseURL, isUITesting: isUITesting)
        rockets = Rockets(apiClient: apiClient, baseURL: baseURL, isUITesting: isUITesting)
    }

    struct Launches {
        private let repository: any LaunchesRepository
        private let isUITesting: Bool

        init(apiClient: any APIClient, baseURL: URL, isUITesting: Bool) {
            self.isUITesting = isUITesting
            if isUITesting {
                repository = UITestingLaunchesRepository()
            } else {
                repository = DefaultLaunchesRepository(apiClient: apiClient, baseURL: baseURL)
            }
        }

        func makeViewModel() -> LaunchesViewModel {
            let calendar = Calendar.current
            let referenceDate = isUITesting ? UITestingData.launchDate : .now
            guard let year = calendar.dateInterval(of: .year, for: referenceDate),
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

    struct Rockets {
        private let repository: any RocketsRepository

        init(apiClient: any APIClient, baseURL: URL, isUITesting: Bool) {
            if isUITesting {
                repository = UITestingRocketsRepository()
            } else {
                repository = DefaultRocketsRepository(apiClient: apiClient, baseURL: baseURL)
            }
        }

        func makeViewModel() -> RocketsViewModel {
            RocketsViewModel(interactor: DefaultRocketsInteractor(repository: repository))
        }

        func makeDetailsViewModel(rocketID: String) -> RocketDetailsViewModel {
            RocketDetailsViewModel(rocketID: rocketID, interactor: DefaultRocketsInteractor(repository: repository))
        }
    }

}
