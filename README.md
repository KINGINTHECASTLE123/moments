# Moments

A social iOS app built with SwiftUI and Firebase where friends can share experiences through games, food, music, and community posts.

## Features

- **Games** — Party games to play with friends
- **Food & Drinks** — Discover and share dishes and drinks
- **Music** — Spotify integration with playlist browsing, track previews, and playback controls
- **Community** — Share posts with photos and interact with friends

## Tech Stack

- **UI**: SwiftUI (iOS 17+)
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Music**: Spotify iOS SDK + Web API
- **Architecture**: MVVM with `@Observable` view models

## Project Structure

```
Moments/
├── Components/        # Reusable UI components
├── Models/            # Data models (Firestore, Spotify, etc.)
├── Services/          # Backend service layer (Firebase, Spotify)
├── ViewModels/        # Observable view models
└── Views/
    ├── Community/     # Posts and social feed
    ├── Food/          # Food & drinks discovery
    ├── Games/         # Party games
    ├── Home/          # Home screen
    ├── Landing/       # Auth flow and tab navigation
    ├── Music/         # Spotify playlists and playback
    ├── Profile/       # User profile and editing
    └── Settings/      # App settings
```

## Setup

1. Clone the repo
2. Open `Moments.xcodeproj` in Xcode
3. Add your `GoogleService-Info.plist` from Firebase Console
4. Configure your Spotify app credentials in `SpotifyService.swift`
5. Build and run on a physical device (Spotify SDK requires a real device)

## Requirements

- iOS 17.0+
- Xcode 16+
- Spotify app installed (for music features)
- Firebase project with Auth, Firestore, and Storage enabled
