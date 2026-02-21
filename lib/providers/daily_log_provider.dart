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
    ref.read(allDailyLogsNotifierProvider.notifier).refresh();
  }

  Future<void> updateNeck(double neck) async {
    final log = state.copyWith(neck: neck);
    await HiveService.dailyLogs.put(date, log);
    state = log;
    ref.read(allDailyLogsNotifierProvider.notifier).refresh();
  }

  Future<void> updateWaist(double waist) async {
    final log = state.copyWith(waist: waist);
    await HiveService.dailyLogs.put(date, log);
    state = log;
    ref.read(allDailyLogsNotifierProvider.notifier).refresh();
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
    ref.read(allDailyLogsNotifierProvider.notifier).refresh();
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
    ref.read(allDailyLogsNotifierProvider.notifier).refresh();
  }

  Future<void> setSleepDuration(int minutes) async {
    final log = state.copyWith(sleepDuration: minutes);
    await HiveService.dailyLogs.put(date, log);
    state = log;
    ref.read(allDailyLogsNotifierProvider.notifier).refresh();
  }

  Future<void> setPhotoPath(String? path) async {
    final log = state.copyWith(photoPath: path);
    await HiveService.dailyLogs.put(date, log);
    state = log;
    ref.read(allDailyLogsNotifierProvider.notifier).refresh();
  }
}

@riverpod
DailyLog todayLog(Ref ref) {
  final now = DateTime.now();
  final date =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  return ref.watch(dailyLogNotifierProvider(date));
}

/// A reactive Notifier for the full sorted list of daily logs.
/// Screens that show history or charts watch this to stay up-to-date.
class _AllDailyLogsNotifier extends Notifier<List<DailyLog>> {
  @override
  List<DailyLog> build() => _load();

  List<DailyLog> _load() {
    return HiveService.dailyLogs.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  void refresh() => state = _load();
}

final allDailyLogsNotifierProvider =
    NotifierProvider<_AllDailyLogsNotifier, List<DailyLog>>(
      _AllDailyLogsNotifier.new,
    );

// Kept for backward compatibility with existing screens.
@riverpod
List<DailyLog> allDailyLogs(Ref ref) {
  return ref.watch(allDailyLogsNotifierProvider);
}
