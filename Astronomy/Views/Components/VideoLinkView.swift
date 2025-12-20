import SwiftUI

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
