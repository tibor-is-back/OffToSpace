import SwiftUI

struct AppRootView: View {
    @State private var launchesViewModel: LaunchesViewModel

    init(launchesViewModel: LaunchesViewModel) {
        _launchesViewModel = State(initialValue: launchesViewModel)
    }

    var body: some View {
        TabView {
            Tab {
                NavigationStack {
                    LaunchesView(viewModel: launchesViewModel)
                }
            } label: {
                tabLabel("app.root.launchesTab", icon: TabIcon.launches)
            }
            .accessibilityIdentifier("root.launchesTab")

            Tab {
                NavigationStack {
                    RocketsView()
                }
            } label: {
                tabLabel("app.root.rocketsTab", icon: TabIcon.rockets)
            }
            .accessibilityIdentifier("root.rocketsTab")
        }
        .tint(DesignSystem.Colors.accent)
    }

    private func tabLabel(_ titleKey: LocalizedStringKey, icon: String) -> some View {
        Label {
            Text(titleKey)
        } icon: {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: DesignSystem.Size.tabIcon, height: DesignSystem.Size.tabIcon)
        }
    }
}

private enum TabIcon {
    static let launches = "LaunchesIcon"
    static let rockets = "RocketIcon"
}

#Preview("Light") {
    AppRootView(launchesViewModel: LaunchesPreviewData.makeViewModel(content: .loaded(LaunchesPreviewData.listItems)))
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    AppRootView(launchesViewModel: LaunchesPreviewData.makeViewModel(content: .loaded(LaunchesPreviewData.listItems)))
        .preferredColorScheme(.dark)
}
