import Kingfisher
import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: APODViewModel
    @State private var selectedDate = Date()
    @State private var showingDatePicker = false
    @State private var selectedImageURL: URL?
    @State private var selectedAPOD: APOD?
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

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

                VStack(spacing: 0) {
                    HStack {
                        NavigationLink(
                            destination: FavouritesView(viewModel: viewModel)
                        ) {
                            HStack(spacing: 6) {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 12))
                                Text("Favourites")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .textCase(.uppercase)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 14)
                            .background(Color(.systemGray6))
                            .cornerRadius(20)
                        }

                        Spacer()

                        Button(action: {
                            withAnimation(.spring()) {
                                showingDatePicker.toggle()
                            }
                        }) {
                            Image(systemName: "calendar")
                                .font(.title3)
                                .foregroundColor(.blue)
                                .padding(8)
                                .background(
                                    showingDatePicker
                                        ? Color.blue.opacity(0.1) : Color.clear
                                )
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)

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
                                withAnimation { showingDatePicker = false }
                            }
                        }
                    }
                }
                .background(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)

                ScrollView {
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding(100)
                    } else if let errorMessage = viewModel.errorMessage {
                        VStack(spacing: 12) {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                            Button("Retry") {
                                Task {
                                    await viewModel.fetchAPOD(for: selectedDate)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                    } else if let apod = viewModel.apod {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(alignment: .top, spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(formatDate(apod.date).uppercased())
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.secondary)

                                    Text(apod.title)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .fixedSize(
                                            horizontal: false,
                                            vertical: true
                                        )
                                }

                                Spacer()

                                Button(action: { viewModel.likeCurrentAPOD() })
                                {
                                    Image(
                                        systemName:
                                            viewModel.isAPODAlreadyLiked(
                                                apod.date
                                            ) ? "heart.fill" : "heart"
                                    )
                                    .font(.title2)
                                    .foregroundColor(.red)
                                    .padding(8)
                                    .background(Color.red.opacity(0.05))
                                    .clipShape(Circle())
                                }
                            }

                            if apod.mediaType == "image",
                                let imageURL = URL(string: apod.url)
                            {
                                ImageViewWithError(imageURL: imageURL) { url in
                                    selectedImageURL = url
                                    selectedAPOD = apod
                                }
                                .cornerRadius(12)
                                .shadow(
                                    color: Color.black.opacity(0.1),
                                    radius: 4,
                                    x: 0,
                                    y: 2
                                )
                            } else if apod.mediaType == "video",
                                let videoURL = URL(string: apod.url)
                            {
                                VideoLinkView(videoURL: videoURL)
                            }

                            Text(apod.explanation)
                                .font(.body)
                                .foregroundColor(.primary.opacity(0.9))
                                .lineSpacing(6)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("NASA APOD")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isDarkMode.toggle()
                    } label: {
                        Image(
                            systemName: isDarkMode
                                ? "sun.max.fill" : "moon.fill"
                        )
                    }
                }
            }
            .fullScreenCover(
                item: Binding(
                    get: {
                        (selectedImageURL != nil && selectedAPOD != nil)
                            ? DetailItem(
                                imageURL: selectedImageURL!,
                                apod: selectedAPOD!
                            ) : nil
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

            .task {

                if viewModel.apod == nil {
                    await viewModel.fetchAPOD(for: selectedDate)
                }
            }
            .refreshable {

                await viewModel.fetchAPOD(for: selectedDate)
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
}

private struct DetailItem: Identifiable {
    let id = UUID()
    let imageURL: URL
    let apod: APOD
}
