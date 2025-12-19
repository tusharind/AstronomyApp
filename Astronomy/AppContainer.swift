import Foundation

final class AppContainer {
    static let shared = AppContainer()
    
    lazy var networkService: NetworkServiceProtocol = {
        NetworkService(config: NetworkConfig.default)
    }()
    
    private init() {}
}

