# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

This is a Flutter application for the Osmangazi University (OGU) student grading system. The app scrapes data from the university's web portal (https://ogubs1.ogu.edu.tr/) to display student grades, academic summaries, and course information. The app features CAPTCHA handling, session management, and a clean Material Design interface.

## Common Development Commands

### Build and Run
```bash
# Get dependencies
flutter pub get

# Run the app (debug mode)
flutter run

# Run on specific device
flutter devices  # List available devices
flutter run -d <device-id>

# Build for specific platforms
flutter build apk           # Android APK
flutter build appbundle     # Android App Bundle
flutter build ios           # iOS (requires macOS)
flutter build windows       # Windows executable
flutter build web           # Web build
```

### Testing and Quality
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage

# Code analysis
flutter analyze

# Format code
dart format .
dart format --set-exit-if-changed .

# Check for outdated dependencies
flutter pub outdated
```

### Generate App Icons
```bash
# Generate launcher icons (configured in pubspec.yaml)
flutter pub get
flutter pub run flutter_launcher_icons:main
```

### Development Workflow
```bash
# Hot reload is automatic in flutter run, but you can also:
# Press 'r' in terminal for hot reload
# Press 'R' in terminal for hot restart
# Press 'q' to quit

# Clean build artifacts
flutter clean
flutter pub get
```

## Architecture Overview

### Clean Architecture with BLoC Pattern

The project follows a feature-based clean architecture with BLoC (Business Logic Component) pattern for state management:

```
lib/
├── core/
│   ├── services/          # Shared services (HTTP client, storage)
│   └── theme/            # App theming and colors
├── features/
│   ├── auth/             # Authentication feature
│   │   ├── data/models/  # Login page data models
│   │   └── presentation/ # BLoC, screens, widgets
│   ├── grades/           # Grades display feature
│   │   ├── data/models/  # Grade and academic models
│   │   └── presentation/ # BLoC, screens, widgets
│   └── schedule/         # Course schedule feature (in development)
└── main.dart            # App entry point with providers
```

### Key Architectural Components

**Core Services:**
- `OgubsService`: Handles all HTTP requests to the university portal, including login, CAPTCHA handling, session management, and data scraping
- `StorageService`: Manages local persistence of user credentials using SharedPreferences

**State Management:**
- Uses `flutter_bloc` for state management across the app
- `AuthBloc`: Manages authentication state, login flow, and session persistence
- `GradesBloc`: Handles grade fetching, term/year filtering, and academic data display

**Data Flow:**
1. User authenticates through login screen with CAPTCHA
2. `OgubsService` scrapes university portal using session cookies
3. BLoC components manage state transitions and UI updates
4. Parsed data models provide type-safe data structures

### Web Scraping Architecture

The app performs sophisticated web scraping of the university's ASP.NET portal:

- **Session Management**: Maintains cookies across requests for authenticated sessions
- **CAPTCHA Handling**: Downloads and displays CAPTCHA images for user input
- **ViewState Parsing**: Extracts ASP.NET ViewState, EventValidation, and ViewStateGenerator for form submissions
- **HTML Parsing**: Uses `html` package to extract structured data from university web pages
- **Error Handling**: Robust timeout and error handling for network requests

### Multi-Platform Support

Configured for deployment across multiple platforms:
- **Android**: APK and App Bundle builds with custom launcher icons
- **iOS**: Native iOS builds (requires macOS)
- **Windows**: Native Windows executable
- **Web**: Progressive Web App deployment
- **Linux/macOS**: Desktop support configured

## Dependencies and Integrations

### Key Dependencies
- `flutter_bloc` ^8.1.6: State management
- `http` ^1.2.2: HTTP requests for web scraping
- `html` ^0.15.4: HTML parsing of university pages
- `shared_preferences` ^2.2.3: Local data persistence
- `google_fonts` ^6.2.1: Custom typography
- `connectivity_plus` ^6.0.3: Network connectivity checking
- `beautiful_soup_dart` ^0.3.0: Additional HTML parsing utilities

### Development Dependencies
- `flutter_test`: Widget and unit testing framework
- `flutter_lints` ^5.0.0: Dart/Flutter linting rules
- `flutter_launcher_icons` ^0.13.1: App icon generation

## Testing Strategy

### Current Test Structure
- `test/widget_test.dart`: Basic widget testing for LoginScreen
- Tests verify UI elements, navigation, and initial state

### Testing Commands for Specific Components
```bash
# Test specific features
flutter test test/ --name="LoginScreen"

# Test with verbose output
flutter test --verbose

# Test in Chrome (for web builds)
flutter test --platform chrome
```

## Development Notes

### University Portal Integration
- **Base URL**: `https://ogubs1.ogu.edu.tr/`
- **Login Endpoint**: `/giris.aspx`
- **Grades Endpoint**: `/SinavSonuc.aspx`
- **Academic Summary**: `/NotDokum.aspx`

### Session Management
The app maintains authenticated sessions through:
- Cookie persistence across HTTP requests
- ViewState tracking for ASP.NET forms
- Automatic session renewal and error handling

### CAPTCHA Handling
- Dynamic CAPTCHA image loading from university portal
- Real-time image display in Flutter UI
- Form submission with CAPTCHA validation

### Localization
Currently supports Turkish language with hardcoded strings. For internationalization, consider implementing `flutter_localizations`.

## Asset Management

### Required Assets
- `assets/images/app_logo.png`: Main application logo
- `assets/images/app_logo_foreground.png`: Foreground for adaptive Android icons

### Asset Configuration
Assets are configured in `pubspec.yaml` under the `flutter.assets` section.