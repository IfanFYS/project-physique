import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/models.dart';
import '../services/hive_service.dart';

part 'user_stats_provider.g.dart';

@riverpod
class UserStatsNotifier extends _$UserStatsNotifier {
  @override
  UserStats build() {
    final stats = HiveService.userStats.get('current');
    if (stats != null) {
      return stats;
    }

    final newStats = UserStats();
    HiveService.userStats.put('current', newStats);
    return newStats;
  }

  Future<void> updateHeight(double height) async {
    final stats = state.copyWith(height: height);
    await HiveService.userStats.put('current', stats);
    state = stats;
  }

  Future<void> updateNeck(double neck) async {
    final stats = state.copyWith(neck: neck);
    await HiveService.userStats.put('current', stats);
    state = stats;
  }

  Future<void> updateWaist(double waist) async {
    final stats = state.copyWith(waist: waist);
    await HiveService.userStats.put('current', stats);
    state = stats;
  }

  Future<void> updateName(String name) async {
    final stats = state.copyWith(name: name);
    await HiveService.userStats.put('current', stats);
    state = stats;
  }

  Future<void> updateMeasurements({
    double? height,
    double? neck,
    double? waist,
    String? name,
  }) async {
    final stats = state.copyWith(
      height: height,
      neck: neck,
      waist: waist,
      name: name ?? state.name,
    );
    await HiveService.userStats.put('current', stats);
    state = stats;
  }

  double? getBMI(double weight) {
    return state.calculateBMI(weight);
  }

  double? getBodyFat(double weight) {
    return state.calculateBodyFat(weight);
  }
}
