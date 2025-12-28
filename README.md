<div align="center">

# Astronomy App

**Explore the cosmos with NASA's Astronomy Picture of the Day**

[![Swift](https://img.shields.io/badge/Swift-5.10-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2017.0+-lightgrey.svg)](https://developer.apple.com/ios/)
[![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-blue.svg)](https://developer.apple.com/xcode/swiftui/)
[![Architecture](https://img.shields.io/badge/Architecture-MVVM-green.svg)](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

</div>

---

## Table of Contents

- [About](#-about)
- [Features](#-features)
- [Screenshots](#-screenshots)
- [Technical Stack](#-technical-stack)
- [Architecture](#-architecture)
- [Installation](#-installation)
- [Usage](#-usage)
- [Testing](#-testing)
- [Contributing](#-contributing)
- [License](#-license)
- [Acknowledgments](#-acknowledgments)

---

## About

A modern, responsive iOS application that explores NASA's **Astronomy Picture of the Day (APOD)**. This project demonstrates clean architecture, robust networking, and high-quality UI implementation using SwiftUI. Whether you're interested in exploring the cosmos or learning modern iOS development patterns, this app showcases production-ready code following best practices.

Built with Swift 5.10 and SwiftUI, the app leverages modern concurrency patterns (async/await) and follows MVVM architecture for maintainability and testability.

---

## Features

### Core Functionality

- **Daily Discoveries**: Automatically fetches and displays the current Astronomy Picture of the Day
- **Media Support**: Smart handling of both high-quality images and video content
- **Historical Exploration**: Interactive Date Picker allows browsing APODs back to June 16, 1995
- **Deep Dive**: Full-screen image detail view with pinch-to-zoom capabilities
- **Resilient Networking**: Graceful error handling for offline states with a built-in retry mechanism
- **Favorites System**: Save and manage your favorite cosmic views locally using Core Data
- **Dark Mode**: Native support for both Light and Dark appearances
- **Efficient Caching**: Integrated Kingfisher for optimized image downloading and disk caching to minimize data usage
- **Sleek UI**: Polished navigation, consistent spacing, and a clean, modern aesthetic

---

## Screenshots

> **Note**: Screenshots to be added showcasing the Home View, Image Detail View, Date Picker, and Favorites screens in both Light and Dark modes.

---

## Technical Stack

| Component | Technology |
|-----------|-----------|
| **Language** | Swift 5.10 |
| **UI Framework** | SwiftUI |
| **Architecture** | MVVM (Model-View-ViewModel) |
| **Concurrency** | Modern Swift Concurrency (Async/Await) |
| **Persistence** | Core Data |
| **Networking** | URLSession with protocol-oriented design |
| **Image Caching** | Kingfisher 8.6.2+ |
| **Minimum iOS** | iOS 17.0+ |
| **IDE** | Xcode 15.0+ |

---

## Architecture

The app follows a clean **MVVM (Model-View-ViewModel)** architecture with clear separation of concerns:

```
Astronomy/
├── App/
│   ├── AstronomyApp.swift          # App entry point
│   └── AppContainer.swift           # Dependency injection container
├── Core/
│   ├── Configuration/               # Configuration files
│   ├── Networking/                  # Network layer
│   │   ├── NetworkService.swift
│   │   ├── NetworkServiceProtocol.swift
│   │   ├── NetworkConfig.swift
│   │   ├── NetworkError.swift
│   │   └── HTTPMethod.swift
│   └── Persistence/                 # Data persistence
│       └── PersistenceController.swift
├── Models/
│   └── APOD.swift                   # Astronomy Picture of the Day model
├── ViewModels/
│   └── APODViewModel.swift          # Business logic & state management
├── Views/
│   ├── RootView.swift               # Root navigation container
│   ├── HomeView.swift               # Main feed view
│   ├── ImageDetailView.swift       # Full-screen image view
│   ├── FavouritesView.swift        # Saved favorites view
│   └── Components/                  # Reusable UI components
│       ├── ImageViewWithError.swift
│       └── VideoLinkView.swift
└── Resources/
    ├── Assets.xcassets              # Images, colors, and icons
    └── Info.plist                   # App configuration
```

### Design Patterns

- **Protocol-Oriented Programming**: Network layer uses protocols for easy testing and flexibility
- **Dependency Injection**: `AppContainer` manages service lifecycle and dependencies
- **MVVM Pattern**: Clear separation between UI (Views), business logic (ViewModels), and data (Models)
- **Repository Pattern**: Centralized data access through `PersistenceController`
- **Modern Concurrency**: Leverages async/await for clean, readable asynchronous code

---

## Installation

### Requirements

- **Xcode**: 15.0 or later
- **iOS**: 17.0 or later
- **macOS**: Ventura 13.0+ (for Xcode compatibility)
- **Swift**: 5.10+

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/AstronomyApp.git
   cd AstronomyApp
   ```

2. **Open the project**
   ```bash
   open Astronomy.xcodeproj
   ```

3. **API Key Configuration**
   
   The app uses NASA's APOD API. Two configuration options are available:
   
   - **Default Mode (Recommended for quick testing)**: The app will use NASA's `DEMO_KEY` automatically upon launch
     - Rate Limit: 30 requests per hour, 50 requests per day
   
   - **Custom API Key (Recommended for development)**:
     1. Get your free API key from [NASA API Portal](https://api.nasa.gov/)
     2. Create a configuration file:
        ```bash
        touch Astronomy/Core/Configuration/Config.xcconfig
        ```
     3. Add your API key:
        ```
        NASA_API_KEY = YOUR_NASA_API_KEY_HERE
        ```
     > **Note**: `Config.xcconfig` is gitignored to protect your API key

4. **Build and Run**
   - Select a target device or simulator (iPhone recommended)
   - Press `Cmd + R` or click the Run button in Xcode
   - The app will launch and automatically fetch today's APOD

---

## Usage

### Browsing Daily APODs

1. Launch the app to view today's Astronomy Picture of the Day
2. Scroll through the image and read the description below
3. Tap the image to enter full-screen mode with zoom capabilities

### Exploring Historical Images

1. Tap the calendar icon in the navigation bar
2. Select any date from June 16, 1995 onwards
3. The app will fetch and display the APOD from that date

### Managing Favorites

1. Tap the star icon on any APOD to add it to favorites
2. Access your favorites by tapping the heart icon in the navigation bar
3. Remove favorites by tapping the star again on any saved APOD

### Handling Videos

- Some APODs are videos instead of images
- The app displays a thumbnail and a "Watch on YouTube" button
- Tap the button to open the video in your browser or YouTube app

---

## Testing

The project includes unit tests to ensure code quality and reliability.

### Running Tests

1. **Via Xcode**:
   - Press `Cmd + U` to run all tests
   - Or select `Product > Test` from the menu

2. **Via Command Line**:
   ```bash
   xcodebuild test -scheme Astronomy -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
   ```

### Test Coverage

- **Network Layer Tests**: Validates API requests and response parsing
- **ViewModel Tests**: Ensures business logic correctness
- **Mock Services**: Uses `MockNetworkService` for isolated unit testing

---

## Contributing

Contributions are welcome! Here's how you can help:

### Reporting Bugs

1. Check if the issue already exists in [Issues](https://github.com/yourusername/AstronomyApp/issues)
2. If not, create a new issue with:
   - Clear description of the bug
   - Steps to reproduce
   - Expected vs actual behavior
   - Screenshots (if applicable)
   - Device and iOS version

### Suggesting Features

1. Open a new issue with the `enhancement` label
2. Describe the feature and its use case
3. Explain why it would benefit the app

### Pull Requests

1. Fork the repository
2. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. Make your changes following the existing code style
4. Write or update tests as needed
5. Commit with clear, descriptive messages:
   ```bash
   git commit -m "Add feature: description of changes"
   ```
6. Push to your fork and submit a pull request
7. Wait for review and address any feedback

### Code Style Guidelines

- Follow Swift API Design Guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Maintain MVVM architecture patterns
- Write unit tests for new features

---

## License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 [Your Name]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## Acknowledgments

- **[NASA APOD API](https://api.nasa.gov/)** - For providing free access to stunning space imagery and data
- **[Kingfisher](https://github.com/onevcat/Kingfisher)** - Excellent Swift library for image downloading and caching
- **Apple SwiftUI Team** - For creating an amazing declarative UI framework
- **Astronomy Community** - For inspiring curiosity about the cosmos

---

<div align="center">

**Made with love by Tushar**

If you found this project helpful, consider giving it a star!

[Report Bug](https://github.com/yourusername/AstronomyApp/issues) · [Request Feature](https://github.com/yourusername/AstronomyApp/issues)

</div>
