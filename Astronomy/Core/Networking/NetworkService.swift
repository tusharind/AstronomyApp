import Foundation

final class NetworkService: NetworkServiceProtocol {
    private let session: URLSession
    private let config: NetworkConfig

    init(session: URLSession = .shared, config: NetworkConfig = .default) {
        self.session = session
        self.config = config
    }

    func request<T: Decodable>(
        path: String,
        method: HTTPMethod = .GET,
        queryParameters: [String: String]? = nil,
        responseType: T.Type
    ) async throws -> T {
        guard var urlComponents = URLComponents(string: config.baseURL + path)
        else {
            throw NetworkError.invalidURL
        }

        if let queryParameters = queryParameters, !queryParameters.isEmpty {
            urlComponents.queryItems = queryParameters.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        }

        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url, timeoutInterval: config.timeout)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet, .networkConnectionLost:
                throw NetworkError.networkUnavailable
            case .timedOut:
                throw NetworkError.timeout
            default:
                throw NetworkError.unknown(error)
            }
        } catch {
            throw NetworkError.unknown(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 401 {
                throw NetworkError.unauthorized
            }
            let errorMessage = String(data: data, encoding: .utf8)
            throw NetworkError.serverError(
                httpResponse.statusCode,
                errorMessage
            )
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
}
