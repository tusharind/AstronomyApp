import Foundation

protocol NetworkServiceProtocol {
    nonisolated func request<T: Decodable>(
        path: String,
        method: HTTPMethod,
        queryParameters: [String: String]?,
        responseType: T.Type
    ) async throws -> T
}
