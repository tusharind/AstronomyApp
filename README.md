# Astronomy App
A modern, responsive iOS application that explores NASA's Astronomy Picture of the Day (APOD). This project demonstrates clean architecture, robust networking, and high-quality UI implementation using SwiftUI.

## Features

### Core Functionality

- Daily Discoveries: Automatically fetches and displays the current Astronomy Picture of the Day.
- Media Support: Smart handling of both high-quality images and video content.
- Historical Exploration: Interactive Date Picker allows browsing APODs back to June 16, 1995.
- Deep Dive: Full-screen image detail view with pinch-to-zoom capabilities.
- Resilient Networking: Graceful error handling for offline states with a built-in retry mechanism.
- Favorites System: Save and manage your favorite cosmic views locally.
- Dark Mode: Native support for both Light and Dark appearances.
- Efficient Caching: Integrated Kingfisher for optimized image downloading and disk caching to minimize data usage.
- Sleek UI: Polished navigation, consistent spacing, and a clean, modern aesthetic.

### Technical Stack

- Language: Swift 5.10
- UI Framework: SwiftUI
- Architecture: MVVM (Model-View-ViewModel)
- Concurrency: Modern Swift Concurrency (Async/Await)
- Third-Party Libraries: Kingfisher (for Image Caching)

### Installation and Setup

1. Requirements
   - Xcode 15.0+
   - iOS 17.0+

2. API Key Configuration
   To ensure the app works immediately for the reviewer, the project is configured with a fallback mechanism.

   - Default Mode: The app will use NASA's `DEMO_KEY` automatically upon launch.
   - Custom Key: For higher rate limits, create a file named `Config.swift` and add:

```swift
struct Config {
    static let apiKey = "YOUR_NASA_API_KEY"
}

