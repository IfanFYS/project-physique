// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_log_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$todayLogHash() => r'49fc80fc32e180f0ccbad830f3e5263635efcbb3';

/// See also [todayLog].
@ProviderFor(todayLog)
final todayLogProvider = AutoDisposeProvider<DailyLog>.internal(
  todayLog,
  name: r'todayLogProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$todayLogHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TodayLogRef = AutoDisposeProviderRef<DailyLog>;
String _$allDailyLogsHash() => r'fa8c3fb0b038819c10bc9e29efec77eb67ca6eda';

/// See also [allDailyLogs].
@ProviderFor(allDailyLogs)
final allDailyLogsProvider = AutoDisposeProvider<List<DailyLog>>.internal(
  allDailyLogs,
  name: r'allDailyLogsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allDailyLogsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllDailyLogsRef = AutoDisposeProviderRef<List<DailyLog>>;
String _$dailyLogNotifierHash() => r'59d6aa8ba01ec832af8a1e99a5fe911ee075bee6';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$DailyLogNotifier
    extends BuildlessAutoDisposeNotifier<DailyLog> {
  late final String date;

  DailyLog build(
    String date,
  );
}

/// See also [DailyLogNotifier].
@ProviderFor(DailyLogNotifier)
const dailyLogNotifierProvider = DailyLogNotifierFamily();

/// See also [DailyLogNotifier].
class DailyLogNotifierFamily extends Family<DailyLog> {
  /// See also [DailyLogNotifier].
  const DailyLogNotifierFamily();

  /// See also [DailyLogNotifier].
  DailyLogNotifierProvider call(
    String date,
  ) {
    return DailyLogNotifierProvider(
      date,
    );
  }

  @override
  DailyLogNotifierProvider getProviderOverride(
    covariant DailyLogNotifierProvider provider,
  ) {
    return call(
      provider.date,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'dailyLogNotifierProvider';
}

/// See also [DailyLogNotifier].
class DailyLogNotifierProvider
    extends AutoDisposeNotifierProviderImpl<DailyLogNotifier, DailyLog> {
  /// See also [DailyLogNotifier].
  DailyLogNotifierProvider(
    String date,
  ) : this._internal(
          () => DailyLogNotifier()..date = date,
          from: dailyLogNotifierProvider,
          name: r'dailyLogNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$dailyLogNotifierHash,
          dependencies: DailyLogNotifierFamily._dependencies,
          allTransitiveDependencies:
              DailyLogNotifierFamily._allTransitiveDependencies,
          date: date,
        );

  DailyLogNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
  }) : super.internal();

  final String date;

  @override
  DailyLog runNotifierBuild(
    covariant DailyLogNotifier notifier,
  ) {
    return notifier.build(
      date,
    );
  }

  @override
  Override overrideWith(DailyLogNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: DailyLogNotifierProvider._internal(
        () => create()..date = date,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<DailyLogNotifier, DailyLog>
      createElement() {
    return _DailyLogNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DailyLogNotifierProvider && other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin DailyLogNotifierRef on AutoDisposeNotifierProviderRef<DailyLog> {
  /// The parameter `date` of this provider.
  String get date;
}

class _DailyLogNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<DailyLogNotifier, DailyLog>
    with DailyLogNotifierRef {
  _DailyLogNotifierProviderElement(super.provider);

  @override
  String get date => (origin as DailyLogNotifierProvider).date;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
