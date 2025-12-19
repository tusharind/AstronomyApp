import SwiftUI
import Kingfisher

@main
struct AstronomyApp: App {
    private let container = AppContainer.shared
    
    init() {
        print(Bundle.main.infoDictionary?["API_KEY"] ?? "NOT FOUND")
        configureKingfisherCache()
    }
    
    private func configureKingfisherCache() {
        // Configure Kingfisher cache settings
        let cache = ImageCache.default
        
        // Set maximum memory cache size (100 MB)
        cache.memoryStorage.config.totalCostLimit = 100 * 1024 * 1024
        cache.memoryStorage.config.countLimit = 50
        
        // Set maximum disk cache size (500 MB)
        cache.diskStorage.config.sizeLimit = 500 * 1024 * 1024
        cache.diskStorage.config.expiration = .days(7) // Keep images for 7 days
        
        // Set default cache expiration
        cache.diskStorage.config.expiration = .days(7)
        cache.memoryStorage.config.expiration = .seconds(300) // 5 minutes in memory
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
