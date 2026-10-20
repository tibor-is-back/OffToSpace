import SwiftUI

@main
struct OffToSpaceApp: App {
    private let dependencies = AppDependencies()

    var body: some Scene {
        WindowGroup {
            AppRootView(dependencies: dependencies)
        }
    }
}
