# Project Physique 💪

A comprehensive fitness tracking app built with Flutter, designed to help you monitor your workouts, track body measurements, log sleep, and visualize your progress over time.

## Features

### 🏠 Home Dashboard
- **Dynamic Greetings**: Changes based on time of day
- **Body Stats**: Weight, Height, BMI, and Body Fat % at a glance
- **Interactive Cards**: Tap Weight/Height cards to update measurements
- **Body Measurements Panel**: Edit Height, Neck, and Waist circumference in one place
- **Calorie Tracker**: Log daily calories with simple input
- **Sleep Tracker**: Monitor sleep duration
- **Quick Workout**: Start and complete workouts directly from home

### 🏋️ Exercise Management
- **Workout Plans**: Create and manage multiple workout routines
- **CRUD Operations**: Full control to Create, Read, Update, Delete workouts
- **Operator Protocol**: Pre-loaded with the 5-day "Operator Protocol" workout plan
  - Heavy Push
  - Heavy Pull
  - Glow Up
  - Chest Hypertrophy
  - Volume
- **Exercise Editor**: Modify exercises, sets, weights, and details

### 📊 Progress Tracking
- **Interactive Charts**: Visualize your progress with fl_chart
  - Weight progression
  - Calorie intake
  - Workout frequency
- **Body Composition**: Automatic BMI and Body Fat % calculation (Navy Method)
- **Historical Data**: Track changes over time

### 📸 Gallery
- **Progress Photos**: Take daily photos to track visual changes
- **Photo Timeline**: Browse through your transformation journey
- **Measurements Overlay**: View stats for each photo date

### 😴 Sleep Mode
- **Sleep Tracking**: Activate sleep mode to track rest duration
- **Testing Mode**: Debug feature to simulate different dates and sleep values

## Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: Riverpod with code generation
- **Database**: Hive (local NoSQL database)
- **Charts**: fl_chart
- **Notifications**: flutter_local_notifications

## Installation

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile)
- Chrome/Edge (for web)

### Steps

1. Clone the repository:
```bash
git clone https://github.com/IfanFYS/project-physique.git
cd project-physique
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:

**Web (Recommended for testing):**
```bash
flutter run -d chrome
# or
flutter run -d edge
```

**Android:**
```bash
flutter run
```

**Windows:**
```bash
flutter run -d windows
```

## Body Fat Calculation

The app uses the **US Navy Method** to estimate body fat percentage:

```
Body Fat % = 495 / (1.0324 - 0.19077 × (waist - neck) / 100 + 0.15456 × (height / 100)) - 450
```

**Requirements:**
- Height (cm)
- Neck circumference (cm) - measure at narrowest point
- Waist circumference (cm) - measure at navel level
- Weight (kg)

## BMI Calculation

```
BMI = weight (kg) / (height (m))²
```

## Testing Features

The app includes a **Testing Mode** (🐛 icon in app bar) that allows you to:
- Simulate different dates
- Manually set sleep duration
- Test app functionality without waiting for real-time data

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Hive data models
│   ├── daily_log.dart
│   ├── exercise.dart
│   ├── workout_day.dart
│   ├── user_stats.dart
│   └── completed_workout.dart
├── providers/                # Riverpod providers
│   ├── daily_log_provider.dart
│   ├── user_stats_provider.dart
│   ├── workout_provider.dart
│   └── sleep_provider.dart
├── screens/                  # UI screens
│   ├── home_screen.dart
│   ├── exercise_screen.dart
│   ├── history_screen.dart
│   ├── progress_screen.dart
│   └── gallery_screen.dart
├── services/                 # Business logic
│   ├── hive_service.dart
│   └── notification_service.dart
├── utils/                    # Utilities
│   ├── theme.dart
│   └── seed_data.dart
└── widgets/                  # Reusable widgets
    └── sleep_mode_overlay.dart
```

## Screenshots

*Screenshots will be added here*

## Roadmap

- [ ] Export data to CSV/PDF
- [ ] Cloud backup/sync
- [ ] Dark mode support
- [ ] Widget support
- [ ] Apple Health / Google Fit integration
- [ ] Custom workout templates
- [ ] Photo comparison tool

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License.

## Acknowledgments

- Built with [Flutter](https://flutter.dev)
- Charts powered by [fl_chart](https://pub.dev/packages/fl_chart)
- Local storage by [Hive](https://pub.dev/packages/hive)
- State management by [Riverpod](https://pub.dev/packages/riverpod)

## Contact

**Project Link:** [https://github.com/IfanFYS/project-physique](https://github.com/IfanFYS/project-physique)

---

Built with 💪 and Flutter
