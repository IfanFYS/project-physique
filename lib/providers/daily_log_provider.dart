import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/models.dart';
import '../services/hive_service.dart';

part 'daily_log_provider.g.dart';

@riverpod
class DailyLogNotifier extends _$DailyLogNotifier {
  @override
  DailyLog build(String date) {
    final log = HiveService.dailyLogs.get(date);
    if (log != null) {
      return log;
    }

    final newLog = DailyLog(date: date);
    HiveService.dailyLogs.put(date, newLog);
    return newLog;
  }

  Future<void> updateWeight(double weight) async {
    final log = state.copyWith(weight: weight);
    await HiveService.dailyLogs.put(date, log);
    state = log;
  }

  Future<void> updateNeck(double neck) async {
    final log = state.copyWith(neck: neck);
    await HiveService.dailyLogs.put(date, log);
    state = log;
  }

  Future<void> updateWaist(double waist) async {
    final log = state.copyWith(waist: waist);
    await HiveService.dailyLogs.put(date, log);
    state = log;
  }

  Future<void> addCalories(int calories) async {
    final entry = CalorieEntry(amount: calories, timestamp: DateTime.now());
    final currentEntries = state.calorieEntries ?? [];
    final updatedEntries = [...currentEntries, entry];

    final log = state.copyWith(
      calories: state.calories + calories,
      calorieEntries: updatedEntries,
    );
    await HiveService.dailyLogs.put(date, log);
    state = log;
  }

  Future<void> removeCalorieEntry(int index) async {
    final currentEntries = state.calorieEntries ?? [];
    if (index < 0 || index >= currentEntries.length) return;

    final removedEntry = currentEntries[index];
    final updatedEntries = List<CalorieEntry>.from(currentEntries)
      ..removeAt(index);

    final log = state.copyWith(
      calories: state.calories - removedEntry.amount,
      calorieEntries: updatedEntries,
    );
    await HiveService.dailyLogs.put(date, log);
    state = log;
  }

  Future<void> setSleepDuration(int minutes) async {
    final log = state.copyWith(sleepDuration: minutes);
    await HiveService.dailyLogs.put(date, log);
    state = log;
  }

  Future<void> setPhotoPath(String? path) async {
    final log = state.copyWith(photoPath: path);
    await HiveService.dailyLogs.put(date, log);
    state = log;
  }
}

@riverpod
DailyLog todayLog(Ref ref) {
  final now = DateTime.now();
  final date =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  return ref.watch(dailyLogNotifierProvider(date));
}

@riverpod
List<DailyLog> allDailyLogs(Ref ref) {
  return HiveService.dailyLogs.values.toList()
    ..sort((a, b) => b.date.compareTo(a.date));
}
