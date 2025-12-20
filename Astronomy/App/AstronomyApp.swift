import Kingfisher
import SwiftUI

@main
struct AstronomyApp: App {
    private let container = AppContainer.shared
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false


    init() {
        print(Bundle.main.infoDictionary?["API_KEY"] ?? "NOT FOUND")
        configureKingfisherCache()
    }

    private func configureKingfisherCache() {
        let cache = ImageCache.default
        cache.memoryStorage.config.totalCostLimit = 100 * 1024 * 1024
        cache.memoryStorage.config.countLimit = 50
        cache.diskStorage.config.sizeLimit = 500 * 1024 * 1024
        cache.diskStorage.config.expiration = .days(7)
        cache.memoryStorage.config.expiration = .seconds(300)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}

