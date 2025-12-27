# FLEKKS - Flexibility & Mobility Training App

> **Your Daily Flexibility Plan** - The Ladder-inspired approach to becoming more flexible and mobile.

FLEKKS is a premium flexibility and mobility training app that brings the team-based coaching model to stretching and mobility work. Built with SwiftUI, it offers personalized daily workouts, expert video coaching, progress tracking, and a supportive community.

---

## Table of Contents

1. [Overview](#overview)
2. [App Architecture](#app-architecture)
3. [Features](#features)
   - [Core Workout Experience](#core-workout-experience)
   - [Team & Community](#team--community)
   - [Progress & Gamification](#progress--gamification)
   - [Music Integration](#music-integration)
   - [Subscription & Monetization](#subscription--monetization)
4. [Technical Stack](#technical-stack)
5. [Project Structure](#project-structure)
6. [Key Files Index](#key-files-index)
   - [App Core](#app-core)
   - [Models](#models)
   - [Services](#services)
   - [Views](#views)
7. [Design System](#design-system)
8. [Backend Integration](#backend-integration)
9. [Third-Party Integrations](#third-party-integrations)
10. [Getting Started](#getting-started)
11. [Ladder Inspiration](#ladder-inspiration)
12. [Roadmap](#roadmap)

---

## Overview

FLEKKS is designed around the philosophy that **consistency beats intensity**. Like Ladder for strength training, FLEKKS provides:

- **Daily personalized flexibility plans** that change weekly
- **Expert coach-led sessions** with video demonstrations
- **Team-based accountability** with coaches and fellow members
- **Progress tracking** specific to flexibility (range of motion, hold times)
- **Gamification** through streaks, badges, and challenges

### Target Audience
- Desk workers with tight hips and shoulders
- Athletes needing mobility work
- Yoga practitioners wanting structured progression
- Anyone pursuing flexibility goals (splits, deeper stretches)

---

## App Architecture

```
FLEKKS/
├── App/                    # App entry, state management
│   ├── FLEKKSApp.swift    # App entry point
│   ├── AppState.swift     # Global state management (@ObservableObject)
│   └── ContentView.swift  # Root navigation controller
├── Models/                 # Data models
│   └── Models.swift       # User, Team, Coach, Session, Program models
├── Services/              # Backend & API services
│   ├── SupabaseService.swift   # Supabase client
│   ├── AuthService.swift       # Authentication
│   ├── DataService.swift       # Data fetching/caching
│   ├── MusicService.swift      # Apple Music/Spotify
│   ├── MuxService.swift        # Video streaming
│   └── ChatService.swift       # Team chat
├── Views/                 # UI Components
│   ├── Onboarding/        # Quiz, team selection
│   ├── Home/              # Home, tab bar
│   ├── Program/           # Sessions, player
│   ├── Team/              # Chat, cheers, selfies
│   ├── Progress/          # Tracking, badges, challenges
│   ├── Profile/           # Settings, referrals
│   ├── Library/           # Saved, scheduled, downloads
│   ├── Subscription/      # Paywall, plans
│   └── Components/        # Reusable UI components
└── Utilities/             # Theme, helpers
    └── Theme.swift        # Colors, fonts, gradients
```

### State Management
- **AppState** (`@EnvironmentObject`): Global app state including user, team, session tracking
- **Service Singletons**: `DataService.shared`, `MusicService.shared` for cross-view state
- **UserDefaults**: Persisted session actions (saved, scheduled, downloads)

---

## Features

### Core Workout Experience

| Feature | Description | File |
|---------|-------------|------|
| **Daily Workout Plan** | Pre-programmed sessions that change weekly | `HomeView.swift` |
| **Video Sessions** | Coach-led workouts with Mux HLS streaming | `SessionPlayerView.swift` |
| **Exercise Timer** | Countdown timer with progress ring | `CurrentExerciseCard` |
| **Progress Bar** | Visual workout completion indicator | `SessionPlayerView.swift` |
| **Rep/Set Tracking** | Log weights, reps, hold times | `SessionDetailView.swift` |
| **Offline Downloads** | Save workouts for offline use | `DownloadsView.swift` |

### Team & Community

| Feature | Description | File |
|---------|-------------|------|
| **Team Selection** | Join coach-led teams by focus area | `TeamSelectionView.swift` |
| **Team Chat** | Real-time messaging with teammates | `TeamChatView.swift` |
| **Coach Announcements** | Pinned messages, announcements | `AnnouncementBanner` |
| **Cheers System** | Send cheers (fire, clap, muscle, etc.) | `CheerSystem.swift` |
| **Selfie Wall** | Post-workout photo sharing | `SelfieWall.swift` |
| **Team Leaderboard** | Rankings by sessions, streak, minutes | `LeaderboardView.swift` |
| **Polls** | Coach polls for team engagement | `PollCard` |

### Progress & Gamification

| Feature | Description | File |
|---------|-------------|------|
| **Streak Tracking** | Daily streak with fire icon | `StreakSystem.swift` |
| **Streak Freeze** | Premium feature to protect streaks | `StreakFreezeSheet` |
| **Badges** | 20+ achievements across 6 categories | `BadgeSystem.swift` |
| **Weekly Challenges** | XP-based challenges with rewards | `WeeklyChallenges.swift` |
| **Flexibility Tracker** | Body area progress with charts | `FlexibilityTracker.swift` |
| **XP System** | Points earned from sessions/badges | `BadgeSystem.swift` |

### Music Integration

| Feature | Description | File |
|---------|-------------|------|
| **Apple Music** | MusicKit integration for playback | `MusicService.swift` |
| **Spotify** | Spotify iOS SDK integration | `MusicService.swift` |
| **Coach Ducking** | Auto-lower volume when coach speaks | `MusicService.startCoachSpeaking()` |
| **Mini Player** | Workout music controls overlay | `MusicMiniPlayer` |
| **Playlist Selection** | Choose workout playlists | `PlaylistPickerSheet` |

### Subscription & Monetization

| Feature | Description | File |
|---------|-------------|------|
| **Free Trial** | 7-day free trial (no CC required) | `SubscriptionView.swift` |
| **Monthly Plan** | $29.99/month | `SubscriptionPlan` |
| **Annual Plan** | $199.99/year (save 44%) | `SubscriptionPlan` |
| **Paywall** | Feature-gated premium content | `PaywallView` |
| **Referral Program** | Earn free time for referrals | `ReferralView.swift` |

---

## Technical Stack

| Technology | Purpose |
|------------|---------|
| **SwiftUI** | UI framework |
| **Supabase** | Backend (PostgreSQL, Auth, Storage, Realtime) |
| **Mux** | Video streaming (HLS) |
| **MusicKit** | Apple Music integration |
| **Spotify iOS SDK** | Spotify playback |
| **HealthKit** | Apple Health sync (planned) |
| **WatchKit** | Apple Watch app (planned) |

---

## Project Structure

### Key Files Index

#### App Core

| File | Description |
|------|-------------|
| `FLEKKS/App/FLEKKSApp.swift` | App entry point, environment setup |
| `FLEKKS/App/AppState.swift` | Global state: user, team, sessions, streaks |
| `FLEKKS/App/ContentView.swift` | Root view, navigation, celebration overlay |

#### Models

| File | Description |
|------|-------------|
| `FLEKKS/Models/Models.swift` | Core data models: User, Team, Coach, Session, Program |

#### Services

| File | Description |
|------|-------------|
| `FLEKKS/Services/SupabaseService.swift` | Supabase client configuration |
| `FLEKKS/Services/AuthService.swift` | Sign up, sign in, session management |
| `FLEKKS/Services/DataService.swift` | Programs, sessions, progress fetching |
| `FLEKKS/Services/MusicService.swift` | Apple Music + Spotify integration |
| `FLEKKS/Services/MuxService.swift` | Video playback with Mux |
| `FLEKKS/Services/ChatService.swift` | Real-time team chat |
| `FLEKKS/Services/CoachService.swift` | Coach data and scheduling |

#### Views

##### Onboarding
| File | Description |
|------|-------------|
| `Views/Onboarding/SplashView.swift` | Launch screen animation |
| `Views/Onboarding/OnboardingView.swift` | Welcome carousel |
| `Views/Onboarding/QuizView.swift` | Personalization quiz |
| `Views/Onboarding/TeamSelectionView.swift` | Choose team/coach |

##### Home & Navigation
| File | Description |
|------|-------------|
| `Views/Home/HomeView.swift` | Today's session, quick actions |
| `Views/Home/TabBarView.swift` | Bottom navigation |

##### Program & Sessions
| File | Description |
|------|-------------|
| `Views/Program/ProgramView.swift` | Weekly program schedule |
| `Views/Program/SessionDetailView.swift` | Session info, action buttons |
| `Views/Program/SessionPlayerView.swift` | Workout player with music |
| `Views/Program/ScheduleSessionSheet.swift` | Schedule workouts |
| `Views/Program/ShareSessionSheet.swift` | Share session links |
| `Views/Program/CelebrationView.swift` | Post-workout celebration |

##### Team & Community
| File | Description |
|------|-------------|
| `Views/Team/TeamChatView.swift` | Enhanced chat with tabs |
| `Views/Team/CheerSystem.swift` | Send cheers, activity feed |
| `Views/Team/SelfieWall.swift` | Post-workout photos |
| `Views/Team/LeaderboardView.swift` | Team rankings |

##### Progress & Tracking
| File | Description |
|------|-------------|
| `Views/Progress/ProgressView.swift` | Progress overview with tabs |
| `Views/Progress/FlexibilityTracker.swift` | Body area progress |
| `Views/Progress/BadgeSystem.swift` | Achievements system |
| `Views/Progress/WeeklyChallenges.swift` | XP challenges |
| `Views/Progress/StreakSystem.swift` | Streak tracking & protection |

##### Profile & Settings
| File | Description |
|------|-------------|
| `Views/Profile/ProfileView.swift` | User profile, settings |
| `Views/Profile/ReferralView.swift` | Invite friends, rewards |

##### Library
| File | Description |
|------|-------------|
| `Views/Library/SavedSessionsView.swift` | Bookmarked sessions |
| `Views/Library/ScheduledSessionsView.swift` | Upcoming workouts |
| `Views/Library/DownloadsView.swift` | Offline content |

##### Subscription
| File | Description |
|------|-------------|
| `Views/Subscription/SubscriptionView.swift` | Paywall, plans |

##### Utilities
| File | Description |
|------|-------------|
| `Utilities/Theme.swift` | Colors, fonts, gradients |
| `Views/Components/Components.swift` | Reusable UI components |

---

## Design System

### Colors

```swift
// Primary palette (dark theme)
.bgPrimary     // #0D0D0D - Main background
.bgCard        // #1A1A1A - Card backgrounds
.bgElevated    // #262626 - Elevated surfaces

// Text colors
.textPrimary   // #FFFFFF
.textSecondary // #A3A3A3
.textMuted     // #737373

// Accent colors
.accent        // Teal primary
.accentLight   // Light teal
.tealBright    // Vibrant teal

// Brand colors
.flekksOrange  // #FF6B35
.flekksRed     // #FF3B30
```

### Typography

```swift
FLEKKSFonts.heading(size)      // Georgia serif
FLEKKSFonts.headingHeavy(size) // System black weight
FLEKKSFonts.bodySemibold(size) // System semibold
FLEKKSFonts.body(size)         // System regular
FLEKKSFonts.labelSmall         // Uppercase tracking
```

### Gradients

```swift
FLEKKSGradients.accentGradient       // Teal gradient
FLEKKSGradients.buttonGradient       // CTA buttons
FLEKKSGradients.heroGreen/Purple/Blue // Team-specific
FLEKKSGradients.tealGlow             // Glow effects
```

---

## Backend Integration

### Supabase Schema

```sql
-- Core tables
users            -- User profiles
teams            -- Coach teams
coaches          -- Coach profiles
programs         -- Training programs
sessions         -- Individual workouts
user_progress    -- Completed sessions
chat_messages    -- Team chat

-- Gamification
badges           -- Achievement definitions
user_badges      -- Earned badges
challenges       -- Weekly challenges
user_challenges  -- Challenge progress
```

### Real-time Features
- Team chat via Supabase Realtime
- Activity feed updates
- Leaderboard sync

---

## Third-Party Integrations

### Music Services

#### Apple Music (MusicKit)
```swift
// Enable in Xcode: Signing & Capabilities > MusicKit
// Add NSAppleMusicUsageDescription to Info.plist

import MusicKit

let status = await MusicAuthorization.request()
let player = ApplicationMusicPlayer.shared
```

#### Spotify
```swift
// Add SpotifyiOS via SPM from github.com/spotify/ios-sdk
// Configure redirect URI in Spotify Developer Dashboard

let configuration = SPTConfiguration(
    clientID: "YOUR_CLIENT_ID",
    redirectURL: URL(string: "flekks://spotify-login-callback")!
)
```

### Video Streaming (Mux)
```swift
// HLS streaming for workout videos
let playbackID = session.muxPlaybackId
let streamURL = "https://stream.mux.com/\(playbackID).m3u8"
```

### Planned Integrations
- **Apple Health**: Workout minutes, heart rate
- **Apple Watch**: Timer, heart rate, controls
- **Strava**: Share completed workouts

---

## Getting Started

### Prerequisites
- Xcode 15+
- iOS 17.0+
- Supabase account
- Mux account (for video)
- Spotify Developer account (optional)

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/Dylan-Flekks/flekks-ios-android.git
   cd flekks-ios-android
   ```

2. **Configure Supabase**
   - Create a Supabase project
   - Update `SupabaseService.swift` with your URL and anon key
   - Run database migrations (see `/supabase/migrations/`)

3. **Configure Signing**
   - Open `FLEKKS.xcodeproj` in Xcode
   - Update bundle identifier
   - Add MusicKit capability

4. **Run**
   ```bash
   open FLEKKS.xcodeproj
   # Select simulator or device, build & run
   ```

---

## Ladder Inspiration

FLEKKS is heavily inspired by [Ladder](https://www.joinladder.com/), the strength training app. Key patterns adopted:

### UI/UX Patterns
- **Daily workout cards** with coach info and quick-start
- **Team-based structure** for accountability
- **Progress bar + timer** during workouts
- **Coach video demonstrations** with form cues
- **Post-workout celebration** with selfie/share prompt
- **Streak prominently displayed** with fire icon

### Gamification Strategies
- **Weekly challenges** with XP rewards
- **Badge system** with milestone achievements
- **Team leaderboards** for friendly competition
- **Streak freezes** as premium perk

### Music Integration
- **Spotify/Apple Music sync** during workouts
- **Auto-ducking** when coach speaks
- **Playlist selection** before starting

### Business Model
- **7-day free trial** (no credit card)
- **Monthly ($29.99) and Annual ($199.99)** tiers
- **Referral rewards** (free time for invites)

### Growth Strategies
- **TikTok/micro-influencer** marketing
- **Creator/coach revenue sharing**
- **Team community** retention mechanics

---

## Roadmap

### Phase 1: Core Experience (Current)
- [x] Daily workout player
- [x] Team selection & chat
- [x] Progress tracking
- [x] Badges & streaks
- [x] Music integration
- [x] Subscription paywall

### Phase 2: Enhanced Features
- [ ] Apple Watch companion app
- [ ] HealthKit integration
- [ ] Offline video downloads
- [ ] AI form feedback
- [ ] Nutrition tracking

### Phase 3: Platform Growth
- [ ] Coach creator tools
- [ ] Live group sessions
- [ ] Android version
- [ ] Web dashboard
- [ ] Corporate wellness programs

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## License

Proprietary - All rights reserved.

---

## Contact

- **Website**: [flekks.app](https://flekks.app)
- **Email**: hello@flekks.app
- **Twitter**: [@flekksapp](https://twitter.com/flekksapp)

---

*Built with love for flexible humans everywhere.*
