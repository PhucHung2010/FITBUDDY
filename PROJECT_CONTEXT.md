# FitBuddy — Project Context for AI Assistants

> **Last Updated:** April 21, 2026
> **Platform:** iOS (SwiftUI, Swift 5)
> **Min Deployment:** iOS 16+
> **IDE:** Xcode

---

## 1. What Is FitBuddy?

FitBuddy is an **AI-powered fitness coaching iOS application** that uses real-time camera-based pose detection to count exercise repetitions, give corrective feedback on form, and track workout history. Users sign in via Google, manage their profile (avatar, bio, username), browse contests, and train with guided exercises.

---

## 2. Architecture Overview

```
FitBuddyApp (@main)
  └── ContentView
        ├── [Authenticated] → WideTabView (Tab Navigation)
        │     ├── Tab: Home      → HomeView
        │     ├── Tab: Fitness   → FitnessView
        │     ├── Tab: Contest   → ContestView
        │     └── Tab: Settings  → AppSettingView
        └── [Unauthenticated]  → LoginView
```

### Global Environment Objects (injected at `FitBuddyApp`)
| Object | Type | Purpose |
|---|---|---|
| `userController` | `UserController` | Local user data holder |
| `supabaseAuthManager` | `SupabaseAuthManager` | Authentication + profile sync |
| `theme` | `AppThemeController` | Light/dark theme controller (injected in `ContentView`) |

### Core Data
- Uses `PersistenceController` for local exercise parameter storage (`ExerciseParameterPersistenceController.swift`).
- Managed Object Context is injected via `.environment(\.managedObjectContext, ...)`.

---

## 3. Directory Structure & File Map

```
FitBuddy/
├── FitBuddyApp.swift              # @main entry point
├── ContentView.swift              # Auth gate: LoginView vs WideTabView
├── Info.plist                     # URL schemes, camera + photo library permissions
│
├── LOGIN_PAGE/
│   ├── LoginView.swift            # Google Sign-In UI
│   └── SupabaseAuthManager.swift  # Auth, profile CRUD, avatar upload to Storage
│
├── USER/
│   ├── UserModel.swift            # UserModel struct (Codable), UserController class
│   └── NotificationView.swift     # Notification UI
│
├── TAB/
│   └── WideTabView.swift          # Main tab navigation (Home, Fitness, Contest, Settings)
│
├── HOME_VIEW/
│   ├── HomeView.swift             # Home tab content
│   ├── CALENDAR/
│   │   ├── Calendar.swift         # Calendar widget
│   │   └── DaySetting.swift       # Day configuration
│   ├── ROUTINE/
│   │   ├── Routine.swift          # Routine management
│   │   └── ExerciseSelectionSheet.swift
│   └── ARCHIVE_BOX/
│       └── ArchiveBox.swift       # Archived exercises
│
├── FITNESS/
│   └── FitnessView.swift          # Fitness tab — exercise browsing grid
│
├── CONTEST/
│   ├── ContestModel.swift         # ContestModel struct + MockContests data
│   └── ContestView.swift          # Contest tab — challenge cards with join button
│
├── EXERCISE_CATEGORY/
│   ├── ExerciseCategory.swift     # ★ LARGE FILE — All exercise definitions
│   │                              #   MuscleGroup enum, Category struct,
│   │                              #   CompletedExerciseInstruction (text),
│   │                              #   CompletedExerciseImageVideoInstruction (assets),
│   │                              #   CompletedExerciseAdjustment (QuickPose params)
│   ├── FitnessExerciseCategory.swift
│   └── ExerciseParameterPersistenceController.swift  # Core Data persistence
│
├── TRAINING/
│   ├── TrainingView.swift         # Training session container
│   ├── POSE_DETECTION/
│   │   ├── PoseDetectionView.swift           # Camera + QuickPose overlay
│   │   ├── FitnessExerciesPerformance.swift  # Rep counting logic
│   │   ├── FitnessExerciesAdjustment.swift   # Angle-based form detection
│   │   ├── Feedback.swift                     # Form correction feedback strings
│   │   └── StatusBarView.swift               # Live status overlay
│   ├── EXERCISE_PARAMETER/
│   │   ├── ExerciseParameterSettingView.swift  # Pre-training config
│   │   ├── ADJUSTMENT/                        # Picker views for reps, time, etc.
│   │   ├── HISTORY_SUMMARY/
│   │   ├── INSTRUCTION/
│   │   └── PREVIEW_IMAGE/
│   └── SUMMARY/
│       ├── SummaryView.swift       # Post-training summary
│       ├── RepSummaryView.swift
│       ├── TimeSummaryView.swift
│       └── FeedbackSummaryView.swift
│
├── APP_SETTING/
│   ├── AppSettingView.swift       # Settings tab
│   ├── AppSignIn/
│   │   ├── UserView.swift         # User profile display card
│   │   ├── ProfileEditView.swift  # Edit profile sheet (PhotosPicker + fields)
│   │   ├── HELPER/AppDelegate.swift
│   │   ├── SCREEN/HomeScreen.swift, LoginScreen.swift
│   │   └── VIEW/CustomButton.swift, GoogleSignInButton.swift, etc.
│   ├── THEME_SETTING/
│   │   └── ThemeSettingView.swift  # Light/dark theme toggle
│   └── DEMO/
│       ├── DemoFeatureOptionView.swift
│       └── WholeBodyDemo.swift
│
├── APP_THEME/
│   ├── AppTheme.swift             # Theme struct (light/dark), AppThemeController
│   └── AppBackground.swift        # Gradient background view
│
├── UI_EFFECTS/                    # Reusable UI components
│   ├── BlurView.swift             # UIVisualEffectView wrapper
│   ├── BlurRoundedBackground.swift # Blur + rounded rect + shadow
│   ├── TabbarFactor.swift         # Tab enum definition (Home, Fitness, Contest, Setting)
│   ├── TabShape.swift             # Custom tab bar shape
│   ├── PositionKeyForTab.swift    # Tab position preference key
│   ├── AppHeading.swift           # Reusable heading component
│   ├── ButtonStyle.swift          # ScaledButtonStyle
│   ├── CustomSheet.swift          # Custom sheet presentation
│   ├── JustifiedText.swift        # Justified text view
│   ├── Slider.swift               # Custom slider
│   ├── copiedButton.swift         # Copy-to-clipboard button
│   └── textFieldModifier.swift    # TextField styling
│
├── RANKING/
│   └── RankingView.swift
│
├── HEALTH_INSURANCE/
│   └── HealthInsuranceView.swift
│
└── ARCHIVE_DRAFT/                 # Unused/experimental code
    ├── UIChallenge.swift
    └── draft1.swift
```

---

## 4. Key Dependencies (Swift Package Manager)

| Package | Version | Purpose |
|---|---|---|
| `supabase-swift` | 2.43.1 | Backend: Auth, Database (PostgREST), Storage |
| `GoogleSignIn-iOS` | — | Google OAuth sign-in |
| `quickpose-ios-sdk` | — | Real-time pose detection via camera |
| `firebase-ios-sdk` | — | Analytics/measurement (via GoogleAppMeasurement) |

---

## 5. Backend — Supabase

### Supabase Project URL
```
https://qovhvfmikpuqstsqqakj.supabase.co
```

### Database Tables

#### `profiles` (public schema)
| Column | Type | Notes |
|---|---|---|
| `id` | uuid (PK, FK → auth.users) | Cascading delete |
| `email` | text | |
| `name` | text | |
| `username` | text | |
| `bio` | text | |
| `avatar_url` | text | Public URL from Storage |
| `updated_at` | timestamptz | Default: now() |

**RLS Policies:**
- SELECT: public (anyone can view)
- INSERT: `auth.uid() = id`
- UPDATE: `auth.uid() = id`

**Trigger:** `on_auth_user_created` — auto-creates a profile row from `auth.users` metadata when a new user signs up.

### Storage Buckets

#### `avatars` (public bucket)
- Stores user avatar images as `{userId}.jpg`
- Upload uses `upsert: true` to overwrite existing avatars
- URLs include `?t={timestamp}` cache-busting parameter
- **Policies:** Authenticated users can INSERT and UPDATE; anyone can SELECT

### Important: Codable Mapping
`UserModel.imageURL` maps to the `avatar_url` database column via `CodingKeys`:
```swift
enum CodingKeys: String, CodingKey {
    case id, name, email, bio, username
    case imageURL = "avatar_url"
}
```

---

## 6. Theming System

The app uses a custom `Theme` struct with light/dark variants:
- `AppThemeController` (ObservableObject) — stores theme preference in `@AppStorage("AppTheme")`
- `theme.main.text` — primary text color
- `theme.main.mainColor` — background color
- `theme.main.ultraThinMaterial` — `UIBlurEffect.Style` for blur backgrounds
- `BlurView` — wraps `UIVisualEffectView` for use in SwiftUI
- `BlurRoundedBackground` — reusable blur + rounded rect + shadow component

> **CRITICAL:** `theme.main.ultraThinMaterial` is a `UIBlurEffect.Style`, NOT a SwiftUI `ShapeStyle`. You **cannot** use it directly in `.background(theme.main.ultraThinMaterial)`. Always wrap it: `.background { BlurView(style: theme.main.ultraThinMaterial) }`.

---

## 7. Exercise & Pose Detection System

### How It Works
1. User selects an exercise from `FitnessView` → opens `ExerciseParameterSettingView`
2. User configures target reps/time → starts `TrainingView` → `PoseDetectionView`
3. `QuickPose` SDK accesses the camera and tracks body landmarks in real-time
4. `FitnessExerciseAdjustment` defines per-exercise parameters:
   - **LimbGroups**: Joint angles to track (e.g., elbow ROM for curls)
   - **GuardGroups**: Body position constraints (e.g., shoulder angle limits)
   - Launch/peak angles determine rep start/end positions
5. `FitnessExercisePerformance` counts reps based on angle transitions
6. `Feedback` system provides real-time corrective cues (e.g., "Raise left arm up")
7. After training → `SummaryView` shows reps, time, and form feedback

### Supported Exercises (16 total)
Squat, Dumbbell Curl, Lateral Raise, Dumbbell Press, Jumping Jack, Walking Lunge, Push-Up, Sit-Up, Front Raise, Swing, High Knees, Deadlift, Pull-Up, Triceps Extension, Hammer Curl, Glute Bridge

### Angle Blur
A global `angleBlur` value (stored in `UserDefaults["globalAngleBlur"]`, default 15.0) determines tolerance for angle matching during rep detection.

---

## 8. Navigation (Tab System)

Defined in `UI_EFFECTS/TabbarFactor.swift`:
```swift
enum Tab: String, CaseIterable {
    case Home, Fitness, Contest, Setting
    var systemImage: String { ... } // house.fill, figure.run, trophy.fill, gearshape.fill
}
```

`WideTabView.swift` implements a custom animated tab bar with blur background and position tracking via `PreferenceKey`.

---

## 9. Contest System (Mock Data)

Currently uses local mock data (`MockContests.current`) defined in `ContestModel.swift`. Each `ContestModel` has:
- `title`, `description`, `dateRange`, `iconSystemName`, `colorHex`
- `pointsReward`, `participantCount`, `isJoined` (toggle)

> **Future:** To make contests live, create a `contests` table in Supabase and fetch data asynchronously.

---

## 10. Common Patterns & Gotchas

### ✅ Do
- Use `BlurView(style: ...)` or `BlurRoundedBackground()` for blur backgrounds
- Use `.environmentObject(theme)` — it's injected at `ContentView` level
- Use `CodingKeys` when Supabase column names differ from Swift property names
- Use `upsert` instead of `update` for profile saves (handles missing rows)
- Append `?t={timestamp}` to storage URLs to bust `AsyncImage` cache

### ❌ Don't
- Don't use `.background(theme.main.ultraThinMaterial)` directly — it's NOT a ShapeStyle
- Don't duplicate `BlurRoundedBackground` — it's globally defined in `UI_EFFECTS/`
- Don't store image data in database columns — upload to Storage, save URL as text
- Don't forget to add new `.swift` files to the Xcode project (`.pbxproj`) — use the `xcodeproj` Ruby gem or add manually in Xcode

### Adding New Files to Xcode Programmatically
```ruby
require 'xcodeproj'
# Install: gem install --user-install xcodeproj
# Then use absolute paths when adding file references
```

---

## 11. Info.plist Permissions

| Key | Value |
|---|---|
| `NSCameraUsageDescription` | "Please allow this app to use your camera for detection" |
| `NSPhotoLibraryUsageDescription` | "Please allow this app to access your photo library for your profile avatar" |
| `GIDClientID` | `841610832624-prbkvi4b9h2t2cn8q58v5eevb8mqcr9n.apps.googleusercontent.com` |
| `CFBundleURLSchemes` | Reversed client ID for Google Sign-In callback |

---

## 12. Supabase Swift SDK v2.43 — Quick Reference

### Database
```swift
// Fetch single
let item: Model = try await supabase.from("table").select().eq("id", value: id).single().execute().value

// Upsert (insert or update)
try await supabase.from("table").upsert(dictData).execute()
```

### Storage
```swift
// Upload (correct parameter labels for v2.43!)
let result = try await supabase.storage
    .from("bucket")
    .upload(fileName, data: fileData, options: FileOptions(contentType: "image/jpeg", upsert: true))
// result.path contains the uploaded file path
```

> **IMPORTANT:** The upload signature is `.upload(path, data:, options:)` — NOT `path:`, `file:`, or `fileOptions:`.
