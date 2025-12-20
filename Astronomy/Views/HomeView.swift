import Kingfisher
import SwiftUI

struct HomeView: View {
    @Environment(\.container) private var container
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

    init() {

        let apiKey =
            Bundle.main.infoDictionary?["API_KEY"] as? String
            ?? Bundle.main.infoDictionary?["NASA_API_KEY"] as? String
            ?? "DEMO_KEY"
        _viewModel = StateObject(
            wrappedValue: APODViewModel(
                networkService: AppContainer.shared.networkService,
                apiKey: apiKey
            )
        )
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {

                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                        Text("Select Date")
                            .font(.headline)
                        Spacer()
                        Button(action: {
                            showingDatePicker.toggle()
                        }) {
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
                        .onChange(of: selectedDate) { oldValue, newValue in
                            Task {
                                await viewModel.fetchAPOD(for: newValue)
                            }
                        }
                    }
                }
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)

                ScrollView {
                    if viewModel.isLoading {
                        VStack {
                            Spacer()
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Loading...")
                                .foregroundColor(.secondary)
                                .padding(.top)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                    } else if let errorMessage = viewModel.errorMessage {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundColor(.red)
                            Text("Error")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text(errorMessage)
                                .foregroundColor(.secondary)
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
                        VStack(alignment: .leading, spacing: 20) {

                            Text(apod.title)
                                .font(.largeTitle)
                                .fontWeight(.bold)

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

                            if let copyright = apod.copyright {
                                Divider()
                                HStack {
                                    Text("© \(copyright)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Astronomy Picture of the Day")
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

struct ImageViewWithError: View {
    let imageURL: URL
    let onTap: (URL) -> Void
    @State private var imageLoadError: Error?

    var body: some View {
        Button(action: {
            onTap(imageURL)
        }) {
            Group {
                if imageLoadError != nil {
                    VStack(spacing: 12) {
                        Image(systemName: "photo")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("Failed to load image")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Tap to try again")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .onTapGesture {
                        imageLoadError = nil
                    }
                } else {
                    KFImage(imageURL)
                        .placeholder {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .frame(height: 300)
                        }
                        .cacheMemoryOnly(false)
                        .fade(duration: 0.25)
                        .onFailure { error in
                            imageLoadError = error
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(12)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct VideoLinkView: View {
    let videoURL: URL
    @State private var videoLoadError: Bool = false

    var body: some View {
        Link(destination: videoURL) {
            VStack(spacing: 12) {
                if videoLoadError {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                    Text("Video may be unavailable")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 50))
                    Text("Watch Video")
                        .font(.headline)
                }
                .foregroundColor(.blue)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

private struct DetailItem: Identifiable {
    let id = UUID()
    let imageURL: URL
    let apod: APOD
}

#Preview {
    HomeView()
        .environment(\.container, AppContainer.shared)
}
