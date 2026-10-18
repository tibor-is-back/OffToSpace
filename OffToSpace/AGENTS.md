# OffToSpace

OffToSpace is a simple (POC) application that shows mission launches and their details and rockets and their details in a tabbed layout. 

## Navigation

- For simplicity other flows use simple SwiftUI naviation with top level NavigationStack and NavigationLink in deeeper levels

## Folder structure

OffToSpace/
├── App/
│   ├── OffToSpace.swift
│   ├── AppDependencies.swift
│   └── AppRootView.swift
├── Core/
│   ├── Networking/
├── DesignSystem/
├── Features/
│   ├── Launches/
│   ├── Rockets/
└── Tests/
    ├── Unit/
    └── UI/

## Architecture
- Layered architecture + MVVM: View -> ViewModel -> Interactor -> Repository -> Networking (GraphQL)
- Interactor layer is responsible for the business logic (for example pagination).
- Define clear boundaries between layers. Use protocols where abstraction, substitution, or mocking is useful.
- The contract between the View and ViewModels are the following:
    - Represent user interactions and view events with a screen-specific enum named <ScreenName>ViewEvent.
```swift
enum LaunchesViewEvent {
    case appeared
    case launchSelected(Launch.ID)
    case retryTapped
}
```
- Ideally, a ViewModel exposes only:
  - one public read-only `state`
  - one public `handle(event:)` method
- Keep dependencies, helper methods, and implementation details private
- Simple editable UI state such as text fields, toggles, sliders, and pickers may use direct bindings when changes do not trigger business logic or side effects. Use ViewEvent for meaningful user intents, lifecycle events, and interactions that trigger behavior.

```swift
@Observable
final class LaunchesViewModel {
    private(set) var state: LaunchesViewState = .loading

    func handle(event: LaunchesViewEvent) {
        // ...
    }

    // Everything else is private.
}
```
- Represent simple screen state with an enum and associated values

```swift
enum LaunchesViewState {
    case loading
    case loaded([Event])
    case empty
    case error
}
```
- Use nested enums when independent parts of the screen have their own meaningful state
- Use a `struct` for state when the number of independent state properties makes an enum cumbersome or leads to excessive combinations
- Views must render state and emit events. Business logic, networking, and data transformation must not live in Views

## Dependency Injection and Composition

- Use constructor-based dependency injection. No singletons.
- AppDependencies is responsible for constructing and owning application-scoped dependencies (e.g. networking, credential storage, user session).
- Group feature-specific dependencies and factories into feature-scoped structs (e.g. Launches, Rockets).
- Feature structs own their repositories and provide factory methods for constructing ViewModels and other feature-specific objects.
- Pass shared application dependencies into feature structs through their initializers.
- Views and ViewModels must not construct repositories or networking dependencies.
- Avoid unnecessary factory abstractions or dependency containers for individual screens.

## General coding rules
- Only generate or modify files explicitly required by the task. Do not automatically create tests, mocks, documentation, or supporting files unless requested or necessary for the implementation.
- Keep SwiftUI layouts as simple as possible. Use the minimum views and modifiers necessary. Avoid unnecessary containers, wrappers, abstractions, and layout complexity.
- Follow the default Swfitlint convention for coding style defined in the .swiftlint file
- Use Observation framework (@Observable)
- Prefer small, testable types
- Error handling rule: no silent catch, no try? unless failure is intentionally ignorable; map low-level errors to domain/presentation errors at boundaries.
- Do not add abstractions for hypothetical future requirements
- Use the Design system for the UI: colours, distances, sizers, etc should all come from the Design System.
- Do not add third party libraries
- Every interactive or test-relevant UI element must have an accessibility ID by default: following this schema: <screen>.<element>
- Where relevant add meaningful accessibilityLabel, Hint or trait.
- Strictly no force unwraps / force casts unless logically guaranteed and clearly justified.
- The app must be localised, every text should use <feature>.<screen>.<element> for the localizable key
- Every class is 'final' by default
- Promote values to named constants when they have semantic meaning or are reused, use AppConstants for App wide constants or create constant files per use-case
- Use modern async-await APIs for all layers and structure concurrency
- Every View should have multiple proper #previews representing its states, create one <feature>PreviewData file for reusable mocks in Views
- We are using Swift 6.4. This means:
    - Assume app code is `@MainActor` isolated by default.
    - Do not treat `async` as meaning "background" or "switch actor". A normal `async` function may suspend while remaining in the caller's isolation context.
    - Use `@concurrent` only when work should explicitly execute concurrently outside the caller's actor isolation
    - Do not use `nonisolated` merely to move work off `MainActor`. `nonisolated` changes actor isolation semantics; `@concurrent` expresses concurrent execution intent.
    - Do not add `@unchecked Sendable` just to silence compiler errors; use it only when thread safety is guaranteed manually.

## Testing

- Unit-test logic and state transitions; don’t add tests that only verify mocks or trivial forwarding.
- Use XCtests for unit tests and XCUITest for UI tests
- Every test case's structure should follow the Gherkin syntax (Given-When-Then)
- Name tests using concise, behavior-oriented camelCase (loadFailureShowsError).
- Every bug fix should include a regression test when practical
- Avoid sleeps in async/UI tests; wait on expectations/predicates instead
- Tests must not depend on network, real backend state, current time, randomness, or execution order
