import Foundation
import SwiftUI
import Combine

@MainActor
class ExampleViewModel: ObservableObject {
    @Published var data: ExampleResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func fetchData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Example GET request
            let response = try await networkService.request(
                path: "/api/endpoint",
                method: .GET,
                queryParameters: ["key": "value"],
                responseType: ExampleResponse.self
            )
            self.data = response
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

// Example response model
struct ExampleResponse: Decodable {
    let id: Int
    let name: String
}


