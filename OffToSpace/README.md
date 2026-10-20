# OffToSpace

A SwiftUI proof of concept for browsing launches and rockets, using MVVM with interactors and repositories.

## Testing

Open `OffToSpace.xcodeproj`, select the `OffToSpace` scheme and an installed iPhone simulator, then run Product → Test (⌘U).

To run from the terminal, substitute an installed simulator name and OS version:

```sh
xcodebuild test -project OffToSpace.xcodeproj -scheme OffToSpace \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5'
```

Use `-only-testing:OffToSpaceTests` for unit tests or `-only-testing:OffToSpaceUITests` for UI tests.

### Offline UI scenarios

UI tests launch with `uiTesting`. `AppDependencies` injects in-memory repositories while retaining the production interactors and ViewModels, so pagination, filtering and presentation logic still run. Normal launches use the API repositories.

The fixtures contain 12 launches and 3 rockets, with varied statuses, active/inactive rockets, and missing optional fields. The initial date range is fixed to the fixture year. Crew-8 is on the second launch page, so its navigation test exercises pagination and scrolling. Tests select stable accessibility IDs and use English for content assertions.

The two UI tests cover:

- Launches → launch details → rocket details, including second-page loading.
- Rockets → rocket details, including scrolling through the list.

Add `uiTesting` to the scheme's Run action to explore the fixtures manually.

Images load from a bundled PNG, with missing-image fixtures exercising the placeholder. The PNG reuses the app's existing rocket illustration. Mission dates, statuses, statistics and imagery are synthetic demonstration data, not a historical SpaceX dataset. External webcast browsing is excluded from these offline tests.

Unit tests cover interactor pagination/filtering, ViewModel loading/error/retry transitions, and repository mapping without a live backend. UI tests check user journeys rather than duplicating every unit-level state transition. These are functional tests, not screenshot comparisons; image appearance should also be reviewed visually.
