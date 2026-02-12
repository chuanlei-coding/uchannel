# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**UChannel - Vita 智能助手** is a personal productivity management application with AI-powered task management. The project migrated from React Native to Flutter in January 2026.

**Architecture:** Hybrid mobile app with Flutter frontend + Java Spring Boot backend

## Essential Commands

### Flutter Development (cd flutter_app/)

```bash
# Install dependencies
flutter pub get

# Run on device/emulator
flutter run

# Build APKs
flutter build apk --debug    # Debug build
flutter build apk --release  # Release build

# Code analysis
flutter analyze

# Run tests
flutter test

# List available devices
flutter devices
```

**Build outputs:**
- Debug: `flutter_app/build/app/outputs/flutter-apk/app-debug.apk`
- Release: `flutter_app/build/app/outputs/flutter-apk/app-release.apk`

### Backend Development

```bash
# Build backend JAR
./scripts/build-backend.sh

# Start backend (default port 8080)
./scripts/start-backend.sh

# Start on specific port
./scripts/start-backend.sh 9090
```

**Service runs on:** `http://localhost:8080` (HTTPS enabled by default)

## Architecture

### Frontend Structure (Flutter)

**Entry point:** `lib/main.dart` - Defines `GoRouter` configuration and app initialization

**Routing:** Uses `go_router` 14.0+ with declarative routing and custom slide transitions
- Routes: `/` (splash), `/chat`, `/schedule`, `/discover`, `/stats`, `/settings`, `/add-todo`
- All pages (except splash and add-todo) are wrapped in `SwipeablePage` for gesture navigation
- Page transitions use `SlideTransition` with easeOut curve

**Key directories:**
- `lib/screens/` - Screen components (7 screens)
- `lib/theme/` - Theme configuration (colors, spacing, shadows, borderRadius, opacity)
- `lib/models/` - Data models (Message, Task)
- `lib/widgets/` - Reusable UI components

**State management:** Provider 6.1+ (simple, lightweight)

**Network layer:** Dio 5.4+ for HTTP requests

**Storage:** SharedPreferences 2.2+ for local data persistence

### UI Component Library

The app has a comprehensive set of reusable components in `lib/widgets/`:

**Navigation & Layout:**
- `BottomNav` - Unified bottom navigation bar (use `BottomNav.defaultNav(currentRoute: '/path')`)
- `PageBackground` - Background decorations with circular gradients
- `PageHeader` - Unified page header with back button, title, and actions
- `SwipeablePage` - Wraps screens for swipe-back gesture navigation
- `BaseCard` - Card container with multiple style variants (default, compact, rounded, soft)

**Form & Input:**
- `AppTextField` - Text input with variants (outlined, filled, multiline, search, readOnly)
- `PrimaryButton` - Main button with variants (filled, outlined, text, sizes, icons, loading state)
- `PrioritySelector` - Priority selection widget (horizontal and vertical)
- `DateTimeSelector` - Date/time picker with styled themes
- `DateSelector` - Standalone date picker

**Feedback & State:**
- `LoadingIndicator` - Loading spinner with multiple sizes and variants
- `SkeletonIndicator` - Shimmer loading placeholder
- `EmptyState` - Empty state display with preset styles (chat, schedule, stats, search, error, network)
- `Toast/SnackBar` - Use Material's `ScaffoldMessenger.showSnackBar()` for now

**List Items:**
- `TaskCard` - Task display card
- `MessageItem` - Chat message bubble
- `SettingTile` / `SettingSection` - Settings list items with switches, arrows, values
- `CardListItem` - Generic list item with icon, title, subtitle, and arrow

### Design System

**Theme constants** (`lib/theme/`):
- `colors.dart` - Brand colors (sage green, teal, terracotta, soft gold, backgrounds, text)
- `spacing.dart` - Spacing scale (xs=4, sm=8, md=16, lg=24, xl=32, xxl=48) with EdgeInsets presets
- `borderRadius.dart` - Border radius scale (xs=4, sm=8, md=12, lg=16, xl=24, xxl=32, full=999)
- `shadows.dart` - Shadow presets (cardSm, cardMd, cardLg, button, fab)
- `opacity.dart` - Opacity values and color extensions for transparency

**Design patterns:**
- Large rounded corners (16px default for cards, 24px for modals, full for buttons)
- Subtle shadows with `AppShadows.cardSm` as default
- Cream background (#FDFBF7) with sage green (#9DC695) as primary brand color
- Consistent 84px height for bottom navigation across all screens

### Backend Structure (Java Spring Boot)

**Entry point:** `backend-java/src/main/java/com/uchannel/PushNotificationApplication.java`

**Configuration:** `backend-java/src/main/resources/application.yml`
- Server port: 8080 (SSL enabled)
- H2 embedded database: `./data/uchannel`
- Firebase FCM integration
- Qwen AI API integration

**Layer architecture:**
- `controller/` - REST endpoints (PushController, ChatController)
- `service/` - Business logic (PushNotificationService, ChatService, QwenFlashService)
- `repository/` - Data access (MessageRepository)
- `model/` - JPA entities (Message)
- `dto/` - Request/response objects
- `config/` - Spring configuration (CorsConfig, FirebaseConfig)

## Development Notes

### Environment Requirements

**Flutter:** Flutter SDK 3.10+, Dart 3.0+, Android Studio / Xcode
**Backend:** JDK 17+, Maven 3.6+

### Key Dependencies

**Flutter:**
- `go_router: ^14.0.0` - Navigation
- `dio: ^5.4.0` - HTTP client
- `provider: ^6.1.1` - State management
- `shared_preferences: ^2.2.2` - Local storage
- `flutter_animate: ^4.5.0` - Animations

### Common Patterns

**Adding a new screen:**
1. Create screen in `lib/screens/`
2. Add route in `lib/main.dart` with `CustomTransitionPage` and `SwipeablePage` wrapper
3. Use `BottomNav.defaultNav(currentRoute: '/your-route')` for bottom navigation
4. Use `PageBackground` or `PageBackground.defaultDecorations()` for background

**Using theme constants:**
```dart
// Spacing
Spacing.lg  // 24.0
Spacing.allLG  // EdgeInsets.all(24)

// BorderRadius
AppBorderRadius.allLG  // BorderRadius.circular(16)
AppBorderRadius.modal  // BorderRadius.circular(32)

// Colors
AppColors.brandSage
AppColors.creamBg
AppColors.darkGrey

// Shadows
AppShadows.cardSm
AppShadows.button

// Opacity
AppColors.black.withValues(alpha: AppOpacity.veryLow)
```

**Common widgets to use:**
- `PrimaryButton(text: 'Submit', onPressed: () {})`
- `AppTextField(hintText: 'Enter text', onChanged: (v) {})`
- `EmptyState.schedule(onAdd: () {})`
- `LoadingIndicator.fullScreen(message: 'Loading...')`
- `PageHeader.simple(title: 'Page Title')`

### Important Files

- `flutter_app/lib/main.dart` - Router configuration (lines 31-141)
- `flutter_app/lib/theme/colors.dart` - All color constants
- `flutter_app/lib/widgets/` - Reusable component library

### Project History

**Migration (January 2026):** Refactored from React Native to Flutter. React Native docs and scripts have been removed.
