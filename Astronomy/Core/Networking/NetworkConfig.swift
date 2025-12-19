import Foundation

struct NetworkConfig {
    let baseURL: String
    
    static let `default` = NetworkConfig(
        baseURL: "https://api.nasa.gov/planetary/apod"
    )
}
