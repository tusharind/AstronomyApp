import Kingfisher
import SwiftUI

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
