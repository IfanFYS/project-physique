import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sleep_provider.g.dart';

@riverpod
class SleepModeNotifier extends _$SleepModeNotifier {
  @override
  ({bool isActive, DateTime? startTime}) build() {
    return (isActive: false, startTime: null);
  }

  void startSleep() {
    state = (isActive: true, startTime: DateTime.now());
  }

  int? endSleep() {
    if (state.startTime != null) {
      final duration = DateTime.now().difference(state.startTime!);
      state = (isActive: false, startTime: null);
      return duration.inMinutes;
    }
    return null;
  }
}
