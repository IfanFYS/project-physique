// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$workoutDaysNotifierHash() =>
    r'0867ae774fea1886fedb6141835d0445aa811a21';

/// See also [WorkoutDaysNotifier].
@ProviderFor(WorkoutDaysNotifier)
final workoutDaysNotifierProvider =
    AutoDisposeNotifierProvider<WorkoutDaysNotifier, List<WorkoutDay>>.internal(
  WorkoutDaysNotifier.new,
  name: r'workoutDaysNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$workoutDaysNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$WorkoutDaysNotifier = AutoDisposeNotifier<List<WorkoutDay>>;
String _$completedWorkoutsNotifierHash() =>
    r'f124ffc79b90106b4719d7ea016e82f55c21db94';

/// See also [CompletedWorkoutsNotifier].
@ProviderFor(CompletedWorkoutsNotifier)
final completedWorkoutsNotifierProvider = AutoDisposeNotifierProvider<
    CompletedWorkoutsNotifier, List<CompletedWorkout>>.internal(
  CompletedWorkoutsNotifier.new,
  name: r'completedWorkoutsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$completedWorkoutsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CompletedWorkoutsNotifier
    = AutoDisposeNotifier<List<CompletedWorkout>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
