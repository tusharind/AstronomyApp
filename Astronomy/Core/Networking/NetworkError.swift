import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingFailed(Error)
    case serverError(Int, String?)
    case unauthorized
    case networkUnavailable
    case timeout
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return
                "Unable to connect. Please check your internet connection and try again."
        case .invalidResponse:
            return
                "Received an invalid response from the server. Please try again later."
        case .decodingFailed:
            return "Unable to process the data. Please try again."
        case .serverError(let code, _):
            switch code {
            case 404:
                return "The requested content was not found."
            case 500...599:
                return
                    "Server is temporarily unavailable. Please try again later."
            default:
                return "Server error occurred. Please try again later."
            }
        case .unauthorized:
            return "Authentication failed. Please check your API key."
        case .networkUnavailable:
            return "No internet connection. Please check your network settings."
        case .timeout:
            return
                "Request timed out. Please check your connection and try again."
        case .unknown(let error):
            if let urlError = error as? URLError {
                switch urlError.code {
                case .notConnectedToInternet, .networkConnectionLost:
                    return
                        "No internet connection. Please check your network settings."
                case .timedOut:
                    return "Request timed out. Please try again."
                case .cannotFindHost, .cannotConnectToHost:
                    return
                        "Cannot connect to server. Please check your internet connection."
                default:
                    return "Network error: \(urlError.localizedDescription)"
                }
            }
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
}
