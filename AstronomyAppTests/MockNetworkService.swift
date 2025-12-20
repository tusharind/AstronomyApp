import SwiftUI

@MainActor
class MockNetworkService: NetworkServiceProtocol {
    var mockAPOD: APOD?
    var shouldReturnError: Bool = false
    var errorToThrow: Error = NetworkError.invalidResponse

    func request<T: Decodable>(
        path: String,
        method: HTTPMethod,
        queryParameters: [String: String]?,
        responseType: T.Type
    ) async throws -> T {
        if await shouldReturnError {
            throw await errorToThrow
        }

        guard let apod = await mockAPOD as? T else {
            throw NetworkError.invalidResponse
        }
        return apod
    }
}
