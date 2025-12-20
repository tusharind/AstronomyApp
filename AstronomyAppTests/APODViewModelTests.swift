import CoreData
import XCTest

@testable import Astronomy

@MainActor
final class APODViewModelTests: XCTestCase {

    var viewModel: APODViewModel!
    var mockService: MockNetworkService!
    var mockContext: NSManagedObjectContext!

    override func setUp() {
        super.setUp()

        let container = NSPersistentContainer(name: "APODModel")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load in-memory store: \(error)")
            }
        }

        mockContext = container.viewContext

        mockService = MockNetworkService()
        viewModel = APODViewModel(
            networkService: mockService,
            context: mockContext,
            apiKey: "TEST_KEY"
        )
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        mockContext = nil
        super.tearDown()
    }

    func testFetchAPODSuccess() async {

        let dummyAPOD = APOD(
            title: "Test Title",
            explanation: "Test explanation",
            date: "2025-12-20",
            url: "https://example.com/image.jpg",
            mediaType: "image",
            copyright: nil
        )
        mockService.mockAPOD = dummyAPOD

        await viewModel.fetchAPOD(for: Date())

        XCTAssertEqual(viewModel.apod?.title, "Test Title")
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testFetchAPODFailure() async {

        mockService.shouldReturnError = true

        await viewModel.fetchAPOD(for: Date())

        XCTAssertNil(viewModel.apod)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }

}
