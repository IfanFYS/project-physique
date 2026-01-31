# Project Physique 💪

A personal fitness tracking app built with Flutter to monitor workouts, track body measurements, log sleep, and visualize progress over time.

**Note:** This is a personal project built for my own fitness journey. Feel free to use or modify it for your own needs!

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
- **Full CRUD**: Create, Read, Update, Delete workouts and exercises
- **Operator Protocol**: Pre-loaded with my 5-day workout plan
  - Heavy Push
  - Heavy Pull
  - Glow Up
  - Chest Hypertrophy
  - Volume

### 📊 Progress Tracking
- **Interactive Charts**: Visualize progress with fl_chart
  - Weight progression
  - Calorie intake
  - Workout frequency
- **Body Composition**: Automatic BMI and Body Fat % calculation (Navy Method)
- **Historical Data**: Track changes over time

### 📸 Gallery
- **Progress Photos**: Take daily photos to track visual changes
- **Photo Timeline**: Browse through transformation journey

### 😴 Sleep Mode
- **Sleep Tracking**: Activate sleep mode to track rest duration
- **Testing Mode**: Debug feature to simulate different dates and sleep values (🐛 icon in app bar)

## Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: Riverpod with code generation
- **Database**: Hive (local NoSQL database)
- **Charts**: fl_chart

## Installation

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK
- Android Studio / Chrome

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

**Web (Easiest for testing):**
```bash
flutter run -d chrome
```

**Android:**
```bash
flutter run
```

## Body Fat Calculation

Uses the **US Navy Method** to estimate body fat percentage:

```
Body Fat % = 495 / (1.0324 - 0.19077 × (waist - neck) / 100 + 0.15456 × (height / 100)) - 450
```

**Required Measurements:**
- Height (cm)
- Neck circumference (cm) - measure at narrowest point
- Waist circumference (cm) - measure at navel level
- Weight (kg)

## BMI Calculation

```
BMI = weight (kg) / (height (m))²
```

## Testing Mode

The 🐛 icon in the app bar opens Testing Mode where you can:
- Simulate different dates
- Manually set sleep duration
- Test app functionality without waiting for real-time data

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Hive data models
├── providers/                # Riverpod providers
├── screens/                  # UI screens (Home, Exercise, History, Progress, Gallery)
├── services/                 # Business logic
├── utils/                    # Utilities
└── widgets/                  # Reusable widgets
```

## Acknowledgments

Built with [Flutter](https://flutter.dev), [Riverpod](https://pub.dev/packages/riverpod), [Hive](https://pub.dev/packages/hive), and [fl_chart](https://pub.dev/packages/fl_chart).

---

Built with 💪 and Flutter by [IfanFYS](https://github.com/IfanFYS)
