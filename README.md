# Flutter App Template

A ready-to-use Flutter template with modern best practices.

## Features

- ✅ **Riverpod 3.x** - Modern state management
- ✅ **Material 3** - Latest design system
- ✅ **Theming** - Preconfigured theme with easy customization
- ✅ **Project Structure** - Organized folders for models, providers, widgets, screens
- ✅ **Local Persistence** - SharedPreferences integration
- ✅ **App Branding** - Ready for flutter_launcher_icons and flutter_native_splash

## Getting Started

### 1. Rename the Project

1. Update `name` in `pubspec.yaml`
2. Update `title` in `lib/main.dart`
3. Change Android package name in `android/app/build.gradle.kts`
4. Change iOS bundle ID in Xcode

### 2. Add Your Branding

1. Replace `assets/app_icon.png` with your app icon
2. Replace `assets/splash_logo.png` with your splash screen logo
3. Run:
   ```bash
   dart run flutter_launcher_icons
   dart run flutter_native_splash:create
   ```

### 3. Customize Theme

Edit the `ThemeData` in `lib/main.dart`:
- Change `seedColor` for primary color
- Adjust `scaffoldBackgroundColor`
- Modify component themes

### 4. Start Building

- Add models to `lib/models/`
- Add providers to `lib/providers/`
- Add widgets to `lib/widgets/`
- Add screens to `lib/screens/`

## Project Structure

```
lib/
├── main.dart           # App entry point & theme
├── models/             # Data models
├── providers/          # Riverpod state management
├── widgets/            # Reusable widgets
└── screens/            # App screens
```

## Commands

```bash
# Get dependencies
flutter pub get

# Run the app
flutter run

# Build for release
flutter build apk
flutter build ios
flutter build web

# Generate app icons
dart run flutter_launcher_icons

# Generate splash screen
dart run flutter_native_splash:create
```

## Notes

- Delete example files when you start building
- Check `pubspec.yaml` for optional dependencies (fl_chart, etc.)
- Remember to run `flutter pub get` after any pubspec changes
