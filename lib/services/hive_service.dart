import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/models.dart';
import '../utils/seed_data.dart';

class HiveService {
  static const String dailyLogsBox = 'dailyLogs';
  static const String workoutDaysBox = 'workoutDays';
  static const String userStatsBox = 'userStats';
  static const String completedWorkoutsBox = 'completedWorkouts';
  static const String appSettingsBox = 'appSettings';

  static late Box<DailyLog> _dailyLogs;
  static late Box<WorkoutDay> _workoutDays;
  static late Box<UserStats> _userStats;
  static late Box<CompletedWorkout> _completedWorkouts;
  static late Box<dynamic> _appSettings;

  static Future<void> initialize() async {
    await Hive.initFlutter();

    Hive.registerAdapter(ExerciseAdapter());
    Hive.registerAdapter(WorkoutDayAdapter());
    Hive.registerAdapter(DailyLogAdapter());
    Hive.registerAdapter(UserStatsAdapter());
    Hive.registerAdapter(CompletedWorkoutAdapter());
    Hive.registerAdapter(CompletedExerciseAdapter());
    Hive.registerAdapter(CalorieEntryAdapter());

    // Create photos directory only on mobile platforms
    if (!kIsWeb) {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final photosDir = Directory('${appDir.path}/photos');
        if (!await photosDir.exists()) {
          await photosDir.create(recursive: true);
        }
      } catch (e) {
        debugPrint('Error creating photos directory: $e');
      }
    }

    _dailyLogs = await Hive.openBox<DailyLog>(dailyLogsBox);
    _workoutDays = await Hive.openBox<WorkoutDay>(workoutDaysBox);
    _userStats = await Hive.openBox<UserStats>(userStatsBox);
    _completedWorkouts = await Hive.openBox<CompletedWorkout>(
      completedWorkoutsBox,
    );
    _appSettings = await Hive.openBox<dynamic>(appSettingsBox);

    await _seedInitialData();
    await _checkDailyReset();
  }

  static Future<void> _seedInitialData() async {
    final hasSeeded = _appSettings.get('hasSeededData') ?? false;

    if (!hasSeeded && _workoutDays.isEmpty) {
      // Seed workout days
      final seedData = SeedData.getInitialWorkoutDays();

      for (final day in seedData) {
        await _workoutDays.put(day.id, day);
      }

      // Seed dummy daily logs with calories and sleep data
      final dummyLogs = SeedData.getDummyDailyLogs();
      for (final log in dummyLogs) {
        await _dailyLogs.put(log.date, log);
      }

      // Seed dummy completed workouts
      final dummyWorkouts = SeedData.getDummyCompletedWorkouts(seedData);
      for (final workout in dummyWorkouts) {
        await _completedWorkouts.put(workout.id, workout);
      }

      await _appSettings.put('hasSeededData', true);
    }
  }

  static Future<void> _checkDailyReset() async {
    final now = DateTime.now();
    final today = _formatDate(now);
    final lastCheckDate = _appSettings.get('lastCheckDate') as String?;

    if (lastCheckDate != today) {
      final existingLog = _dailyLogs.get(today);
      if (existingLog == null) {
        final newLog = DailyLog(date: today, calories: 0);
        await _dailyLogs.put(today, newLog);
      } else if (_formatDate(now) != lastCheckDate) {
        existingLog.calories = 0;
        await existingLog.save();
      }

      await _appSettings.put('lastCheckDate', today);
    }
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static Box<DailyLog> get dailyLogs => _dailyLogs;
  static Box<WorkoutDay> get workoutDays => _workoutDays;
  static Box<UserStats> get userStats => _userStats;
  static Box<CompletedWorkout> get completedWorkouts => _completedWorkouts;
  static Box<dynamic> get appSettings => _appSettings;

  static Future<void> clearAllData() async {
    await _dailyLogs.clear();
    await _workoutDays.clear();
    await _userStats.clear();
    await _completedWorkouts.clear();
    await _appSettings.clear();
  }
}
