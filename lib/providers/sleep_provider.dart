import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/hive_service.dart';

part 'sleep_provider.g.dart';

@riverpod
class SleepModeNotifier extends _$SleepModeNotifier {
  @override
  ({bool isActive, DateTime? startTime}) build() {
    final startTimeStr =
        HiveService.appSettings.get('sleepStartTime') as String?;
    if (startTimeStr != null) {
      final startTime = DateTime.tryParse(startTimeStr);
      if (startTime != null) {
        return (isActive: true, startTime: startTime);
      }
    }
    return (isActive: false, startTime: null);
  }

  void startSleep() {
    final now = DateTime.now();
    HiveService.appSettings.put('sleepStartTime', now.toIso8601String());
    state = (isActive: true, startTime: now);
  }

  int? endSleep() {
    if (state.startTime != null) {
      final duration = DateTime.now().difference(state.startTime!);
      HiveService.appSettings.delete('sleepStartTime');
      state = (isActive: false, startTime: null);
      return duration.inMinutes;
    }
    return null;
  }
}
