# Moments

A social iOS app built with SwiftUI and Firebase where friends can share experiences through games, food, music, and community posts.

## Features

- **Games** — Party games to break the ice and spark the night
- **Food & Drinks** — Curated dishes and pairings across starters, mains, desserts, and cocktails
- **Music** — Spotify integration with playlist browsing, track listing, and playback controls via App Remote
- **Community** — Share posts with photos, like and comment on friends' moments
- **Profile** — Customizable profile with avatar, bio, interests, stats, and favorites
- **Settings** — Dark mode, notifications, moment reminders, haptic feedback, account management (email/password change, delete account), and connected accounts

## Tech Stack

- **UI**: SwiftUI (iOS 17+)
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Music**: Spotify iOS SDK (App Remote) + Spotify Web API
- **Architecture**: MVVM with `@Observable` view models and protocol-based services
- **Image Handling**: Custom two-tier image cache (NSCache + disk) with compression before upload

## Project Structure

```
Moments/
├── Components/        # Reusable UI (HairlineCard, PillTag, SectionHeader, UserAvatarView, etc.)
├── Constants/         # AppConstants (interests) and StorageKeys
├── Models/            # Data models (UserProfile, FirestorePost, FirestoreDish, SpotifyModels)
├── Services/          # Backend services (Auth, User, Post, Food, Storage, Spotify, ImageCache, etc.)
├── ViewModels/        # @Observable @MainActor view models
└── Views/
    ├── Community/     # Posts feed, post creation, post detail with comments
    ├── Food/          # Food & drinks discovery by category
    ├── Games/         # Party games catalog, game detail, and gameplay
    ├── Home/          # Home dashboard with navigation cards
    ├── Landing/       # Auth flow (sign in, create account, forgot password) and tab navigation
    ├── Music/         # Spotify playlists, playlist detail, now playing controls
    ├── Profile/       # User profile and edit profile
    └── Settings/      # App settings, change email/password, connected accounts
```

## Architecture

- **Services** define a protocol (e.g., `PostServiceProtocol`) with a concrete implementation (`PostService`). All services are `Sendable`.
- **ViewModels** are `@Observable @MainActor` classes that depend on service protocols. They are created as `@State` in `MomentsApp` and injected into the view hierarchy via `.environment()`.
- **Views** access ViewModels through `@Environment`.
- **Design system** is centralized in `MomentsStyle` — all colors, fonts, and radii come from there.

## Setup

1. Clone the repo
2. Open `Moments.xcodeproj` in Xcode
3. Add your `GoogleService-Info.plist` from the [Firebase Console](https://console.firebase.google.com/)
4. Copy `Secrets.xcconfig.example` to `Secrets.xcconfig` and fill in your Spotify client ID
5. Build and run on a physical device (Spotify App Remote requires a real device)

## Requirements

- iOS 17.0+
- Xcode 16+
- Spotify app installed on device (for music features)
- Firebase project with Auth, Firestore, and Storage enabled
