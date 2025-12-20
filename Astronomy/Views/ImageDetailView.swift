import Kingfisher
import SwiftUI

struct ImageDetailView: View {
    let imageURL: URL
    let apod: APOD
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var showingMetadata = true
    @State private var imageLoadError: Error?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            // Image with gestures
            Group {
                if let _ = imageLoadError {
                    VStack(spacing: 16) {
                        Image(systemName: "photo")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("Failed to load image")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text("Please check your internet connection")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Button("Retry") {
                            imageLoadError = nil
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    KFImage(imageURL)
                        .placeholder {
                            ProgressView()
                                .tint(.accentColor)
                        }
                        .cacheMemoryOnly(false)
                        .fade(duration: 0.25)
                        .onFailure { error in imageLoadError = error }
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    let delta = value / lastScale
                                    lastScale = value
                                    scale = min(max(scale * delta, 1.0), 5.0)
                                }
                                .onEnded { _ in
                                    lastScale = 1.0
                                    if scale <= 1.0 {
                                        offset = .zero
                                        lastOffset = .zero
                                    }
                                }
                                .simultaneously(
                                    with: DragGesture(minimumDistance: 0)
                                        .onChanged { value in
                                            if scale > 1.0 {
                                                offset = CGSize(
                                                    width: lastOffset.width + value.translation.width,
                                                    height: lastOffset.height + value.translation.height
                                                )
                                            }
                                        }
                                        .onEnded { _ in lastOffset = offset }
                                )
                        )
                        .simultaneousGesture(
                            TapGesture(count: 2)
                                .onEnded {
                                    withAnimation {
                                        if scale > 1.0 {
                                            resetZoom()
                                        } else {
                                            scale = 2.0
                                            lastScale = 1.0
                                            lastOffset = .zero
                                            offset = .zero
                                        }
                                    }
                                }
                        )
                }
            }
            
            // Top buttons (always visible)
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .background(Circle().fill(Color(.systemBackground).opacity(0.5)))
                    }
                    .padding()
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation { showingMetadata.toggle() }
                    }) {
                        Image(systemName: "info.circle.fill")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .background(Circle().fill(Color(.systemBackground).opacity(0.5)))
                    }
                    .padding()
                }
                
                Spacer()
            }
            
            // Metadata overlay (only content)
            if showingMetadata {
                VStack {
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text(apod.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(formatDate(apod.date))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(apod.explanation)
                            .font(.body)
                            .foregroundColor(.primary)
                            .lineLimit(4)
                        
                        if let copyright = apod.copyright {
                            Divider()
                                .background(Color.secondary.opacity(0.3))
                            
                            HStack {
                                Text("© \(copyright)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground).opacity(colorScheme == .dark ? 0.7 : 0.9))
                    )
                    .padding()
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .navigationBarHidden(true)
        .statusBarHidden(true)
        .onAppear { resetZoom() }
    }
    
    private func resetZoom() {
        withAnimation {
            scale = 1.0
            offset = .zero
            lastOffset = .zero
            lastScale = 1.0
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

#Preview {
    ImageDetailView(
        imageURL: URL(string: "https://apod.nasa.gov/apod/image/2301/M42_HubbleGendler_960.jpg")!,
        apod: APOD(
            title: "Example Title",
            explanation: "This is an example explanation of the astronomy picture of the day.",
            date: "2023-01-01",
            url: "https://apod.nasa.gov/apod/image/2301/M42_HubbleGendler_960.jpg",
            mediaType: "image",
            copyright: "Example Copyright"
        )
    )
}

