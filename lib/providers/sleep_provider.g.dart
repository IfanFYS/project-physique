// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sleepModeNotifierHash() => r'37ec663fe5e5c2f2af7b419d5cdbb4728ea50547';

/// See also [SleepModeNotifier].
@ProviderFor(SleepModeNotifier)
final sleepModeNotifierProvider = AutoDisposeNotifierProvider<SleepModeNotifier,
    ({bool isActive, DateTime? startTime})>.internal(
  SleepModeNotifier.new,
  name: r'sleepModeNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sleepModeNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SleepModeNotifier
    = AutoDisposeNotifier<({bool isActive, DateTime? startTime})>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
