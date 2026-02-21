# Project Physique - Agent Notes

## App Progress

### Current Status
**Last Updated:** 2026-02-25

The Gym/Fitness tracking app is **functionally complete** and running successfully on both Chrome (web) and Android Emulator.

### Completed Features

#### Core Features ✅
- **Home Screen**: Weight tracking, calorie logging, sleep tracking, workout completion
- **Workout Plans**: Create, edit, delete workout plans and exercises
- **History**: View daily logs with workouts, calories, sleep, BMI, body fat %
- **Progress Charts**: Weight, calories, workouts, measurements (neck/waist), sleep trends
- **Gallery**: Progress photos with transformation mode, camera/gallery integration
- **Sleep Mode**: Timer overlay with notification support
- **Data Persistence**: Hive database for local storage

#### Data Models
- DailyLog (weight, calories, sleep, measurements, photos)
- WorkoutDay & Exercise (workout planning)
- CompletedWorkout (workout history)
- UserStats (height, neck, waist, name, BMI/body fat calculations)
- CalorieEntry (timestamped calorie entries)

#### UI/UX
- Material 3 design with custom teal/cyan theme
- Dark mode support
- Responsive layouts (fixed overflow issues in Gallery)
- Bottom navigation (5 tabs)
- Sleep mode overlay with timer

### Known Issues

#### Bug #1 - Sleep Recording Date ✅ FIXED
**Status:** Fixed (2026-02-21)
**Issue:** When waking up, sleep duration was recorded for "yesterday" instead of "today"
**Location:** `lib/widgets/sleep_mode_overlay.dart` lines 154-162
**Fix:** Changed to use `now` (today's date) instead of `yesterday`

#### Bug #2 - UI Overflow (Fixed ✅)
**Status:** Fixed
**Issue:** Gallery empty state buttons overflowed on small screens
**Fix:** Changed Row to Wrap widget in gallery_screen.dart line 87-107

#### Bug #3 - DailyLog.copyWith Cannot Clear Nullable Fields ✅ FIXED
**Status:** Fixed (2026-02-21)
**Issue:** Calling `copyWith(sleepDuration: null)` wouldn't clear sleepDuration because `??` treated null as "not provided"
**Location:** `lib/models/daily_log.dart`
**Fix:** Replaced `??` pattern with Object sentinel pattern - each nullable field uses `Object? field = _sentinel` so null can be explicitly passed

#### Bug #4 - allDailyLogs Not Reactive ✅ FIXED
**Status:** Fixed (2026-02-21)
**Issue:** Progress and History screens didn't update when weight/calories were logged on the Home screen
**Location:** `lib/providers/daily_log_provider.dart`
**Fix:** Added a hand-written `_AllDailyLogsNotifier` (NotifierProvider) with a `refresh()` method. Every mutation method in `DailyLogNotifier` now calls this refresh.

#### Bug #5 - Daily Calorie Reset Bug ✅ FIXED
**Status:** Fixed (2026-02-21)
**Issue:** When app was reopened on a new day, `_checkDailyReset` would reset existing day's calories to 0 even if data already existed
**Location:** `lib/services/hive_service.dart`
**Fix:** Removed the incorrect `else if` branch that was wiping calories - only create a blank log if none exists for today

#### Bug #6 - TextEditingController Memory Leak ✅ FIXED  
**Status:** Fixed (2026-02-21)
**Issue:** `TextEditingController` for calorie input was created inside `_buildCalorieTracker()` (called every build), causing memory leaks
**Location:** `lib/screens/home_screen.dart`
**Fix:** Moved controller to state class (`_calorieController`) with `dispose()` lifecycle management

#### Bug #7 - Progress Calorie Chart Crash ✅ FIXED
**Status:** Fixed (2026-02-21)
**Issue:** Calorie chart called `reduce()` on an empty list, causing StateError crash
**Location:** `lib/screens/progress_screen.dart`
**Fix:** Added `isNotEmpty` guard before `reduce()`, defaults `maxY` to 500

#### Bug #8 - History Screen Hardcoded Dates
**Status:** Fixed (2026-02-21)
**Issue:** Empty-state fallback in History screen used hardcoded dates `['2026-02-02', ...]`
**Location:** `lib/screens/history_screen.dart`
**Fix:** Generate dates dynamically relative to `DateTime.now()`

#### Bug #9 - Gallery Screen Crashes on Web ✅ FIXED
**Status:** Fixed (2026-02-25)
**Issue:** `Image.file()` crashes on Flutter web because `dart:io` File API is unavailable. Also `_addSampleData` test button was present.
**Location:** `lib/screens/gallery_screen.dart`
**Fix:** Rewrote gallery_screen.dart - uses `Image.network()` on web, `Image.file()` on native. Added `kIsWeb` guard throughout. Removed 'Add Demo Data' test button.

#### Bug #10 - Gallery PageView Not Synced with Thumbnail Strip ✅ FIXED
**Status:** Fixed (2026-02-25)
**Issue:** Tapping a thumbnail did not jump the main PageView to the selected photo
**Location:** `lib/screens/gallery_screen.dart`
**Fix:** Added `PageController _pageController` - thumbnails call `_pageController.animateToPage()` and the PageView uses this controller.

#### Bug #11 - Gallery Transformation Slider divisions: 0 crash ✅ FIXED
**Status:** Fixed (2026-02-25)
**Issue:** If start/end range was the same index, `divisions: 0` would crash the RangeSlider
**Location:** `lib/screens/gallery_screen.dart`
**Fix:** Clamped divisions to minimum 1: `divisions: rangeSpan > 0 ? rangeSpan : 1`

### Testing Instructions

## How to Run Tests

### Option 1: Chrome (Web) - Quick Testing
```bash
flutter run -d chrome --web-port=8080
```
**Best for:** UI testing, quick feature checks  
**Limitations:** No camera, no notifications, limited storage persistence

### Option 2: Android Emulator (Full Testing)

#### Prerequisites
- Android Studio with emulator installed
- Flutter SDK configured

#### Launch Emulator
```bash
# List available emulators
flutter emulators

# Launch emulator (use your emulator ID)
flutter emulators --launch Medium_Phone_API_36.1

# Wait 15 seconds for emulator to start

# Verify device is connected
flutter devices

# Run the app
flutter run -d emulator-5554
```

#### Android Configuration (Already Applied)
The following fix was applied to `android/app/build.gradle.kts` for notifications:
```kotlin
compileOptions {
    isCoreLibraryDesugaringEnabled = true
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
```

### Testing Checklist

#### Persistent Storage
1. Open app on emulator
2. Add weight, calories, complete a workout
3. Close app (swipe away or press back)
4. Reopen app - verify all data persists

#### Gallery/Photos
- Go to Gallery tab
- Test camera: Tap Camera button (requires emulator camera setup)
- Test gallery picker: Tap Gallery button (in AppBar or empty state)
- Verify photos save and display in both grid view and transformation mode
- Verify thumbnail strip syncs correctly with main PhotoView

#### Notifications
- Go to Home tab
- Tap moon icon OR "Go to Sleep" button
- Check status bar for persistent notification
- Tap notification to return to app
- Tap "Wake Up" to end sleep mode

#### Navigation
- Test all 5 bottom tabs
- Verify smooth transitions
- Check responsive layouts on different screen sizes

#### Data Calculations
- Set height, weight, neck, waist measurements
- Verify BMI calculation displays
- Verify Body Fat % calculation displays
- Check progress charts update correctly

### Physical Device Testing

#### Connect USB Device
```bash
# Enable USB debugging on phone
# Connect via USB
flutter devices  # Should list your phone
flutter run -d <device-id>
```

#### Build Release APK
```bash
flutter build apk --release
# Install: build/app/outputs/flutter-apk/app-release.apk
```

## Code Structure

```
lib/
├── main.dart                    # App entry, navigation
├── models/                      # Data models with Hive adapters
│   ├── daily_log.dart
│   ├── exercise.dart
│   ├── workout_day.dart
│   ├── user_stats.dart
│   ├── completed_workout.dart
│   └── calorie_entry.dart
├── providers/                   # Riverpod state management
│   ├── daily_log_provider.dart
│   ├── workout_provider.dart
│   ├── user_stats_provider.dart
│   ├── sleep_provider.dart
│   └── navigation_provider.dart
├── screens/                     # UI screens
│   ├── home_screen.dart
│   ├── exercise_screen.dart
│   ├── history_screen.dart
│   ├── progress_screen.dart
│   └── gallery_screen.dart
├── services/                    # Backend services
│   ├── hive_service.dart       # Database initialization
│   └── notification_service.dart
├── utils/                       # Utilities
│   ├── theme.dart              # AppTheme class
│   └── seed_data.dart          # Initial workout plans
└── widgets/                     # Reusable widgets
    └── sleep_mode_overlay.dart
```

## Dependencies
- **State Management:** flutter_riverpod, riverpod_annotation
- **Database:** hive, hive_flutter
- **Charts:** fl_chart
- **Notifications:** flutter_local_notifications
- **Image/Camera:** image_picker
- **File System:** path_provider, path
- **Utilities:** intl, uuid

### 📸 Gallery Improvements ✅
**Status:** Completed (2026-02-21)
- **BMI & BFP Overlays**: Photo cards now display BMI and Body Fat % alongside weight.
- **Accurate BFP**: Calculations in the gallery use per-day measurements (Neck/Waist) from the `DailyLog` if available, falling back to global `UserStats`.
- **UI Refinement**: Stats are displayed in clean "pills" or stat rows with better typography.

### 📊 Progress Chart UX Pro ✅
**Status:** Completed (2026-02-21)
- **Top-Right Controls**: Range selector (7d, 14d, 30d, All) moved to the top-right of the chart area for easier access.
- **Zoom & Pan**: Added `InteractiveViewer` support to charts, allowing users to zoom in/out and pan through data.
- **Clean UI**: Removed selector checkmarks and improved button styling.
- **30-Day Testing Data**: Expanded seed data generation from 14 to 30 days to better test charts and gallery features.

### Known Issues
- None at this time. All reported issues fixed.

### Next Steps / TODO
- [x] ~~Fix Gallery BMI/BFP display inconsistencies~~ ✅
- [x] ~~Improve Chart Controls UI/UX (Range selector, zoom/pan)~~ ✅
- [x] ~~Add 30-day dummy data for testing~~ ✅
- [ ] **Physical Device Testing**: Improve UI for trackers/graph and test in real phone (Touch targets, spacing)
- [ ] **Notifications & Reminders**:
  - Add sleep reminder notification
  - Add daily tracker (Weight) reminder
  - Add workout reminder notifications
- [ ] Implement data export/import (JSON/CSV)
- [ ] Add workout streak tracking
- [ ] Implement achievements/badges system
- [ ] Add social sharing for progress photos

## Notes for Session (2026-02-21)
- Focus was on visual polish and data density.
- Gallery screen now provides much more useful context for progress photos.
- Progress screen feels more "pro" with zoom/pan and cleaner controls.
- Seeding logic updated to provide 30 days of data for better stress testing of the UI.

---
**Environment:** Flutter 3.35.7, Dart 3.9.2, Android SDK 36  
**Last Update:** 2026-02-21 - Gallery Photo Stats & Chart UX Pro Max

