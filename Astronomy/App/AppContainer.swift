import Foundation
import CoreData


final class AppContainer {
    static let shared = AppContainer()

    lazy var networkService: NetworkServiceProtocol = {
        NetworkService(config: NetworkConfig.default)
    }()
    
    let persistenceController: PersistenceController = .shared

        var context: NSManagedObjectContext {
            persistenceController.context
        }

    private init() {}
}
