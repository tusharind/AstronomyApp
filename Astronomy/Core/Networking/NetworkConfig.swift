import Foundation

struct NetworkConfig {
    let baseURL: String
    let timeout: TimeInterval

    static let `default` = NetworkConfig(
        baseURL: "https://api.nasa.gov",
        timeout: 30
    )
}
