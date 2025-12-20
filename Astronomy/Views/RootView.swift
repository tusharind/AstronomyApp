import SwiftUI

struct RootView: View {


    var body: some View {
        HomeView(
            viewModel: APODViewModel(
                networkService: AppContainer.shared.networkService,
                context: AppContainer.shared.context,
                apiKey: Bundle.main.infoDictionary?["API_KEY"] as? String ?? "DEMO_KEY"
            )
        )
    }
}
