# Moments

A social iOS app built with SwiftUI and Firebase where friends can share experiences through games, food, music, and community posts.

<!-- Add screenshots here: -->
<!-- ![Screenshots](assets/screenshots.png) -->

## Features

- **Games** — Party games to break the ice and spark the night
- **Food & Drinks** — Curated dishes and pairings across starters, mains, desserts, and cocktails
- **Music** — Spotify integration with playlist browsing, track listing, and playback controls via App Remote
- **Community** — Share posts with photos, like and comment on friends' moments
- **Profile** — Customizable profile with avatar, bio, interests, stats, and favorites
- **Settings** — Dark mode, notifications, moment reminders, haptic feedback, and account management

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **UI** | SwiftUI (iOS 17+) |
| **Backend** | Firebase Auth, Firestore, Storage |
| **Music** | Spotify iOS SDK (App Remote) + Web API |
| **Architecture** | MVVM with `@Observable` view models and protocol-based services |
| **Image pipeline** | Two-tier cache (NSCache + disk) with compression before upload |
| **Localisation** | Danish and English |

## Architecture

```
Moments/
├── Components/        # Reusable UI (HairlineCard, PillTag, SectionHeader, …)
├── Constants/         # App-wide constants and localised strings
├── Models/            # Data models (UserProfile, FirestorePost, SpotifyModels, …)
├── Services/          # Protocol-based services (Auth, Post, Spotify, ImageCache, …)
├── ViewModels/        # @Observable @MainActor view models
└── Views/
    ├── Community/     # Posts feed, creation, detail with comments
    ├── Drinks/        # Cocktail and drink discovery
    ├── Food/          # Dish discovery by category
    ├── Games/         # Party games catalog and gameplay
    ├── Home/          # Dashboard with navigation cards
    ├── Landing/       # Auth flow and tab navigation
    ├── Moments/       # Create and view live moments
    ├── Music/         # Spotify playlists and now-playing controls
    ├── Profile/       # User profile and editing
    └── Settings/      # App settings and account management
```

- **Services** define a protocol (e.g. `PostServiceProtocol`) with a concrete `Sendable` implementation.
- **ViewModels** are `@Observable @MainActor` classes injected into the view hierarchy via `.environment()`.
- **Views** pull ViewModels from `@Environment` — no singletons, no global state.
- **Design system** is centralised in `MomentsStyle` — all colours, fonts, and radii come from one place.

## Getting Started

1. Clone the repo
2. Open `Moments.xcodeproj` in Xcode 16+
3. Add your own `GoogleService-Info.plist` from the [Firebase Console](https://console.firebase.google.com/)
4. Copy `Secrets.xcconfig.example` → `Secrets.xcconfig` and add your Spotify client ID
5. Build and run on a physical device (Spotify App Remote requires a real device)

## Requirements

- iOS 17.0+
- Xcode 16+
- Spotify app installed on device (for music features)
- Firebase project with Auth, Firestore, and Storage enabled

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
