import SwiftUI

struct LaunchesRootView: View {
    @State private var path: [LaunchesRoute] = []
    private let launches: AppDependencies.Launches
    private let rockets: AppDependencies.Rockets

    init(launches: AppDependencies.Launches, rockets: AppDependencies.Rockets) {
        self.launches = launches
        self.rockets = rockets
    }

    var body: some View {
        NavigationStack(path: $path) {
            LaunchesView(viewModel: launches.makeViewModel()) { id in
                path.append(.launch(id))
            }
            .navigationDestination(for: LaunchesRoute.self, destination: destination)
        }
    }

    @ViewBuilder
    private func destination(for route: LaunchesRoute) -> some View {
        switch route {
        case .launch(let id):
            LaunchDetailsView(viewModel: launches.makeDetailsViewModel(launchID: id)) { rocketID in
                path.append(.rocket(rocketID))
            }
        case .rocket(let id):
            RocketDetailsView(viewModel: rockets.makeDetailsViewModel(rocketID: id))
        }
    }

}

private enum LaunchesRoute: Hashable {
    case launch(String)
    case rocket(String)
}

#Preview("Light") {
    let dependencies = AppDependencies(isUITesting: true)
    LaunchesRootView(launches: dependencies.launches, rockets: dependencies.rockets)
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    let dependencies = AppDependencies(isUITesting: true)
    LaunchesRootView(launches: dependencies.launches, rockets: dependencies.rockets)
        .preferredColorScheme(.dark)
}
