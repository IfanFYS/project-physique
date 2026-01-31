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

  Future<void> addCalories(int calories) async {
    final log = state.copyWith(calories: state.calories + calories);
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
  final date = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  return ref.watch(dailyLogNotifierProvider(date));
}

@riverpod
List<DailyLog> allDailyLogs(Ref ref) {
  return HiveService.dailyLogs.values.toList()
    ..sort((a, b) => b.date.compareTo(a.date));
}
