import SwiftUI

struct HomeView: View {
    @Environment(\.container) private var container
    @StateObject private var viewModel: APODViewModel
    @State private var selectedDate = Date()
    @State private var showingDatePicker = false
    @State private var selectedImageURL: URL?
    @State private var selectedAPOD: APOD?
    
    // Date range for the picker
    private var dateRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let earliest = calendar.startOfDay(for: APODViewModel.earliestAPODDate)
        return earliest...today
    }
    
    init() {
        // Get API key from bundle or use demo key
        // Check for both API_KEY and NASA_API_KEY for flexibility
        let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String 
                  ?? Bundle.main.infoDictionary?["NASA_API_KEY"] as? String 
                  ?? "DEMO_KEY"
        _viewModel = StateObject(wrappedValue: APODViewModel(
            networkService: AppContainer.shared.networkService,
            apiKey: apiKey
        ))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Date Picker Section
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
                            Image(systemName: showingDatePicker ? "chevron.up" : "chevron.down")
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
                
                // Content Section
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
                        // Title
                        Text(apod.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        // Date
                        Text(formatDate(apod.date))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        // Image or Video Thumbnail
                        if apod.mediaType == "image", let imageURL = URL(string: apod.url) {
                            Button(action: {
                                selectedImageURL = imageURL
                                selectedAPOD = apod
                            }) {
                                AsyncImage(url: imageURL) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 300)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .cornerRadius(12)
                                    case .failure:
                                        Image(systemName: "photo")
                                            .font(.system(size: 100))
                                            .foregroundColor(.gray)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 300)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        } else if apod.mediaType == "video", let videoURL = URL(string: apod.url) {
                            Link(destination: videoURL) {
                                HStack {
                                    Image(systemName: "play.circle.fill")
                                        .font(.system(size: 50))
                                    Text("Watch Video")
                                        .font(.headline)
                                }
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        
                        // Explanation
                        Text(apod.explanation)
                            .font(.body)
                            .lineSpacing(4)
                        
                        // Copyright
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
            .fullScreenCover(item: Binding(
                get: { selectedImageURL != nil && selectedAPOD != nil ? DetailItem(imageURL: selectedImageURL!, apod: selectedAPOD!) : nil },
                set: { if $0 == nil { selectedImageURL = nil; selectedAPOD = nil } }
            )) { item in
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

// Helper struct for full screen cover
private struct DetailItem: Identifiable {
    let id = UUID()
    let imageURL: URL
    let apod: APOD
}

#Preview {
    HomeView()
        .environment(\.container, AppContainer.shared)
}

