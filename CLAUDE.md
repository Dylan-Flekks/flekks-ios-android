# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

This is a native iOS SwiftUI app. Open in Xcode and build:
```bash
open FLEKKS.xcodeproj
# Build: Cmd+B
# Run: Cmd+R (select simulator or device)
```

**Requirements:** Xcode 15+, iOS 17.0+

**Capabilities to enable:** MusicKit (for Apple Music integration)

## Architecture Overview

### State Management
- **AppState** (`FLEKKS/App/AppState.swift`): Central `@ObservableObject` managing navigation, auth, team, session state. Injected via `@EnvironmentObject` throughout the app.
- **Service Singletons**: `AuthService.shared`, `DataService.shared`, `MusicService.shared` for cross-view state
- **UserDefaults**: Persists session actions (saved, scheduled, downloaded sessions)

### Navigation Flow
`AppScreen` enum controls screens: `splash → onboarding → quiz → teamSelection → auth → main`

`Tab` enum for main tab bar: `home | program | team | progress | profile`

### Key Services
| Service | Purpose |
|---------|---------|
| `SupabaseService` | Backend client (PostgreSQL, Auth, Realtime) |
| `AuthService` | Sign up/in, session management |
| `DataService` | Programs, sessions, progress fetching |
| `MusicService` | Apple Music + Spotify with coach audio ducking |
| `MuxService` | HLS video streaming |
| `ChatService` | Real-time team chat |

### View Organization
Views follow a feature-based structure under `FLEKKS/Views/`:
- `Onboarding/` - Splash, welcome carousel, quiz, team selection
- `Home/` - Today's workout, tab bar
- `Program/` - Weekly schedule, session detail, video player, celebration
- `Team/` - Chat, cheers, selfie wall, leaderboard
- `Progress/` - Tracking, badges, streaks, challenges
- `Profile/` - Settings, referrals
- `Library/` - Saved, scheduled, downloads
- `Subscription/` - Paywall

## Design System

Uses a custom theme defined in `FLEKKS/Utilities/Theme.swift`:

**Colors** (dark theme):
- Backgrounds: `.bgPrimary`, `.bgCard`, `.bgElevated`
- Text: `.textPrimary`, `.textSecondary`, `.textMuted`
- Accent: `.accent` (teal), `.accentLight`, `.accentSecondary`

**Typography** - SF Pro Rounded throughout:
- `FLEKKSFonts.heading(size)` / `.headingHeavy(size)`
- `FLEKKSFonts.body(size)` / `.bodySemibold(size)`
- `FLEKKSFonts.mono(size)` for timers

**Button Styles:** `PrimaryButtonStyle`, `SecondaryButtonStyle`, `TealGlowButtonStyle`

**Card Modifiers:** `.cardStyle()`, `.glowCardStyle()`

**Gradients:** `FLEKKSGradients.buttonGradient`, `.heroTeal`, `.tealGlow`, etc.

## Backend

Uses Supabase for:
- PostgreSQL database (users, teams, coaches, programs, sessions, progress)
- Authentication
- Realtime subscriptions (chat, activity feed)
- Storage (videos, images)

Video streaming via Mux HLS.

## Key Patterns

- All UI is SwiftUI with iOS 17+ features
- Dark mode only (`.preferredColorScheme(.dark)`)
- Async/await for all service calls
- `@MainActor` on AppState and view models
- Hex color extension: `Color(hex: "00d4aa")`
