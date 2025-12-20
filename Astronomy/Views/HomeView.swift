import Kingfisher
import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: APODViewModel
    @State private var selectedDate = Date()
    @State private var showingDatePicker = false
    @State private var selectedImageURL: URL?
    @State private var selectedAPOD: APOD?

    private var dateRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let earliest = calendar.startOfDay(for: APODViewModel.earliestAPODDate)
        return earliest...today
    }

    init(viewModel: APODViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {

                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                        Text("Select Date")
                            .font(.headline)
                        Spacer()
                        Button(action: { showingDatePicker.toggle() }) {
                            Text(formatDateForDisplay(selectedDate))
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            Image(
                                systemName: showingDatePicker
                                    ? "chevron.up" : "chevron.down"
                            )
                            .foregroundColor(.blue)
                            .font(.caption)
                        }
                    }
                    .padding(.horizontal)

                    if showingDatePicker {
                        DatePicker(
                            "Select Date",
                            selection: $selectedDate,
                            in: dateRange,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.graphical)
                        .padding(.horizontal)
                        .onChange(of: selectedDate) { _, newValue in
                            Task {
                                await viewModel.fetchAPOD(for: newValue)
                            }
                        }
                    }

                    NavigationLink(
                        destination: FavouritesView(viewModel: viewModel)
                    ) {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                            Text("View Favourites")
                                .font(.headline)
                        }
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)

                ScrollView {
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                    } else if let errorMessage = viewModel.errorMessage {
                        VStack(spacing: 12) {
                            Text(errorMessage)
                                .foregroundColor(.red)
                            Button("Retry") {
                                Task {
                                    await viewModel.fetchAPOD(for: selectedDate)
                                }
                            }
                            .padding(8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .padding()
                    } else if let apod = viewModel.apod {
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Text(apod.title)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                Spacer()
                                Button(action: {
                                    viewModel.likeCurrentAPOD()
                                }) {
                                    Image(
                                        systemName:
                                            viewModel.isAPODAlreadyLiked(
                                                apod.date
                                            )
                                            ? "heart.fill" : "heart"
                                    )
                                    .font(.title2)
                                    .foregroundColor(.red)
                                }
                            }

                            Text(formatDate(apod.date))
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            if apod.mediaType == "image",
                                let imageURL = URL(string: apod.url)
                            {
                                ImageViewWithError(imageURL: imageURL) { url in
                                    selectedImageURL = url
                                    selectedAPOD = apod
                                }
                            } else if apod.mediaType == "video",
                                let videoURL = URL(string: apod.url)
                            {
                                VideoLinkView(videoURL: videoURL)
                            } else {
                                VStack(spacing: 12) {
                                    Image(systemName: "questionmark.circle")
                                        .font(.system(size: 50))
                                        .foregroundColor(.gray)
                                    Text("Unsupported media type")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 200)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                            }

                            Text(apod.explanation)
                                .font(.body)
                                .lineSpacing(4)
                        }
                        .padding()
                    } else {

                        VStack(spacing: 12) {
                            Text("No data available.")
                                .foregroundColor(.secondary)
                            Button("Retry") {
                                Task {
                                    await viewModel.fetchAPOD(for: selectedDate)
                                }
                            }
                            .padding(8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                    }
                }
            }
            .navigationTitle("Picture of the Day")
            .refreshable {
                await viewModel.fetchAPOD(for: selectedDate)
            }
            .task {
                if viewModel.apod == nil {
                    await viewModel.fetchAPOD(for: selectedDate)
                }
            }
            .fullScreenCover(
                item: Binding(
                    get: {
                        selectedImageURL != nil && selectedAPOD != nil
                            ? DetailItem(
                                imageURL: selectedImageURL!,
                                apod: selectedAPOD!
                            )
                            : nil
                    },
                    set: {
                        if $0 == nil {
                            selectedImageURL = nil
                            selectedAPOD = nil
                        }
                    }
                )
            ) { item in
                ImageDetailView(imageURL: item.imageURL, apod: item.apod)
            }
        }
    }

    private func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMMM d, yyyy"
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        return dateString
    }

    private func formatDateForDisplay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
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
    HomeView(viewModel: dummyVM)
}
