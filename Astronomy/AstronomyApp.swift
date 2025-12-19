import SwiftUI

@main
struct AstronomyApp: App {
    private let container = AppContainer.shared
    
    init() {
            print(Bundle.main.infoDictionary?["API_KEY"] ?? "NOT FOUND")
        }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.container, container)
        }
    }
}

// Environment key for dependency injection
struct ContainerKey: EnvironmentKey {
    static let defaultValue = AppContainer.shared
}

extension EnvironmentValues {
    var container: AppContainer {
        get { self[ContainerKey.self] }
        set { self[ContainerKey.self] = newValue }
    }
}
