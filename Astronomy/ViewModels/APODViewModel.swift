import Combine
import CoreData
import Foundation
import SwiftUI

@MainActor
class APODViewModel: ObservableObject {
    @Published var apod: APOD?
    @Published var likedAPODs: [APOD] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let networkService: NetworkServiceProtocol
    private let context: NSManagedObjectContext
    private let apiKey: String

    static let earliestAPODDate: Date = {
        var components = DateComponents()
        components.year = 1995
        components.month = 6
        components.day = 16
        return Calendar.current.date(from: components) ?? Date()
    }()

    init(
        networkService: NetworkServiceProtocol,
        context: NSManagedObjectContext,
        apiKey: String
    ) {
        self.networkService = networkService
        self.context = context
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

//    func likeCurrentAPOD() {
//        guard let apod = apod else { return }
//
//        if isAPODAlreadyLiked(apod.date) {
//            return
//        }
//
//        let entity = APODEntity(context: context)
//        entity.title = apod.title
//        entity.explanation = apod.explanation
//        entity.date = apod.date
//        entity.url = apod.url
//        entity.mediaType = apod.mediaType
//
//        do {
//            try context.save()
//            fetchLikedAPODs()
//        } catch {
//            print("Failed to save APOD: \(error)")
//        }
//    }

//    func fetchLikedAPODs() {
//        let request: NSFetchRequest<APODEntity> = APODEntity.fetchRequest()
//        request.sortDescriptors = [
//            NSSortDescriptor(keyPath: \APODEntity.date, ascending: false)
//        ]
//
//        do {
//            let results = try context.fetch(request)
//            likedAPODs = results.map { entity in
//                APOD(
//                    title: entity.title ?? "",
//                    explanation: entity.explanation ?? "",
//                    date: entity.date ?? "",
//                    url: entity.url ?? "",
//                    mediaType: entity.mediaType ?? "",
//                    copyright: nil
//                )
//            }
//        } catch {
//            print("Failed to fetch liked APODs: \(error)")
//        }
//    }
    
    func likeCurrentAPOD() {
        guard let apod = apod else { return }

        if isAPODAlreadyLiked(apod.date) {
            print("APOD for \(apod.date) is already liked.")
            return
        }

        let entity = APODEntity(context: context)
        entity.title = apod.title
        entity.explanation = apod.explanation
        entity.date = apod.date
        entity.url = apod.url
        entity.mediaType = apod.mediaType

        do {
            try context.save()
            print("Saved APOD locally: \(apod.title) on \(apod.date)")
            fetchLikedAPODs()
        } catch {
            print("Failed to save APOD: \(error)")
        }
    }

    func fetchLikedAPODs() {
        let request: NSFetchRequest<APODEntity> = APODEntity.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \APODEntity.date, ascending: false)
        ]

        do {
            let results = try context.fetch(request)
            likedAPODs = results.map { entity in
                APOD(
                    title: entity.title ?? "",
                    explanation: entity.explanation ?? "",
                    date: entity.date ?? "",
                    url: entity.url ?? "",
                    mediaType: entity.mediaType ?? "",
                    copyright: nil
                )
            }
            print("Currently liked APODs (\(likedAPODs.count)):")
            for apod in likedAPODs {
                print("• \(apod.title) (\(apod.date))")
            }
        } catch {
            print("Failed to fetch liked APODs: \(error)")
        }
    }


    func unlikeAPOD(_ apodToDelete: APOD) {
        let request: NSFetchRequest<APODEntity> = APODEntity.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@", apodToDelete.date)

        do {
            let results = try context.fetch(request)
            for entity in results {
                context.delete(entity)
            }
            try context.save()
            fetchLikedAPODs()
        } catch {
            print("Failed to delete APOD: \(error)")
        }
    }

    func isAPODAlreadyLiked(_ date: String) -> Bool {
        let request: NSFetchRequest<APODEntity> = APODEntity.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@", date)
        request.fetchLimit = 1

        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            return false
        }
    }
}
