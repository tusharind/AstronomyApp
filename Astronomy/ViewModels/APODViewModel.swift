import Combine
import Foundation
import SwiftUI

@MainActor
class APODViewModel: ObservableObject {
    @Published var apod: APOD?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let networkService: NetworkServiceProtocol
    private let apiKey: String

    static let earliestAPODDate: Date = {
        var components = DateComponents()
        components.year = 1995
        components.month = 6
        components.day = 16
        return Calendar.current.date(from: components) ?? Date()
    }()

    init(networkService: NetworkServiceProtocol, apiKey: String) {
        self.networkService = networkService
        self.apiKey = apiKey
    }

    func validateDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selectedDate = calendar.startOfDay(for: date)
        let earliestDate = calendar.startOfDay(for: Self.earliestAPODDate)

        return selectedDate >= earliestDate && selectedDate <= today
    }

    func fetchAPOD(for date: Date? = nil) async {
        isLoading = true
        errorMessage = nil

        // Validate date if provided
        if let date = date, !validateDate(date) {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            errorMessage =
                "Date must be between June 16, 1995 and today. Selected: \(formatter.string(from: date))"
            isLoading = false
            return
        }

        do {
            var queryParameters: [String: String] = ["api_key": apiKey]

            if let date = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                queryParameters["date"] = formatter.string(from: date)
            }

            let response = try await networkService.request(
                path: "/planetary/apod",
                method: .GET,
                queryParameters: queryParameters,
                responseType: APOD.self
            )
            self.apod = response
        } catch let error as NetworkError {
            self.errorMessage = error.errorDescription ?? "An error occurred"
        } catch {

            if let urlError = error as? URLError {
                switch urlError.code {
                case .notConnectedToInternet, .networkConnectionLost:
                    self.errorMessage =
                        "No internet connection. Please check your network settings."
                case .timedOut:
                    self.errorMessage = "Request timed out. Please try again."
                default:
                    self.errorMessage =
                        "Network error: \(urlError.localizedDescription)"
                }
            } else {
                self.errorMessage = error.localizedDescription
            }
        }

        isLoading = false
    }
}
