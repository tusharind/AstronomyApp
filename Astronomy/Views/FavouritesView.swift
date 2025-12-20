import Kingfisher
import SwiftUI

struct FavouritesView: View {
    @ObservedObject var viewModel: APODViewModel
    @State private var selectedAPOD: APOD?
    @State private var selectedImageURL: URL?

    var body: some View {
        List {
            ForEach(viewModel.likedAPODs, id: \.date) { apod in
                Button(action: {
                    if let url = URL(string: apod.url) {
                        selectedImageURL = url
                        selectedAPOD = apod
                    }
                }) {
                    HStack(spacing: 12) {
                        if let url = URL(string: apod.url),
                            apod.mediaType == "image"
                        {
                            KFImage(url)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipped()
                                .cornerRadius(8)
                        } else {
                            Image(systemName: "photo")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.gray)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(apod.title)
                                .font(.headline)
                                .lineLimit(2)
                            Text(formatDate(apod.date))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Favourites")
        .onAppear {
            viewModel.fetchLikedAPODs()
        }
        .fullScreenCover(
            item: Binding(
                get: {
                    selectedAPOD != nil && selectedImageURL != nil
                        ? DetailItem(
                            imageURL: selectedImageURL!,
                            apod: selectedAPOD!
                        )
                        : nil
                },
                set: { _ in
                    selectedAPOD = nil
                    selectedImageURL = nil
                }
            )
        ) { item in
            ImageDetailView(imageURL: item.imageURL, apod: item.apod)
        }
    }

    private func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"

        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .medium

        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        return dateString
    }
}

private struct DetailItem: Identifiable {
    let id = UUID()
    let imageURL: URL
    let apod: APOD
}

#Preview {
    let dummyVM = APODViewModel(
        networkService: AppContainer.shared.networkService,
        context: AppContainer.shared.context,
        apiKey: "DEMO_KEY"
    )
    FavouritesView(viewModel: dummyVM)
}
