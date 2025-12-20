import SwiftUI

struct FavouritesView: View {
    @ObservedObject var viewModel: APODViewModel

    var body: some View {
        NavigationView {
            List {
                if viewModel.likedAPODs.isEmpty {
                    Text("No favourites yet.")
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    ForEach(viewModel.likedAPODs, id: \.date) { apod in
                        Text(apod.title)
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .navigationTitle("Favourites")
            .toolbar {
                EditButton()
            }
            .onAppear {
                viewModel.fetchLikedAPODs()
            }
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let apod = viewModel.likedAPODs[index]
            viewModel.unlikeAPOD(apod)
        }
    }
}

#Preview {
    let dummyVM = APODViewModel(
        networkService: AppContainer.shared.networkService,
        context: AppContainer.shared.context,
        apiKey: "DEMO_KEY"
    )
    FavouritesView(viewModel: dummyVM)
}
