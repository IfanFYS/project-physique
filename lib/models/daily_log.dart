import 'package:hive/hive.dart';
import 'calorie_entry.dart';

part 'daily_log.g.dart';

@HiveType(typeId: 2)
class DailyLog extends HiveObject {
  @HiveField(0)
  late String date;

  @HiveField(1)
  double? weight;

  @HiveField(2)
  late int calories;

  @HiveField(3)
  int? sleepDuration;

  @HiveField(4)
  String? photoPath;

  @HiveField(5)
  List<CalorieEntry>? calorieEntries;

  @HiveField(6)
  double? neck;

  @HiveField(7)
  double? waist;

  DailyLog({
    required this.date,
    this.weight,
    this.calories = 0,
    this.sleepDuration,
    this.photoPath,
    this.calorieEntries,
    this.neck,
    this.waist,
  });

  DailyLog copyWith({
    String? date,
    Object? weight = _sentinel,
    int? calories,
    Object? sleepDuration = _sentinel,
    Object? photoPath = _sentinel,
    Object? calorieEntries = _sentinel,
    Object? neck = _sentinel,
    Object? waist = _sentinel,
  }) {
    return DailyLog(
      date: date ?? this.date,
      weight: weight == _sentinel ? this.weight : weight as double?,
      calories: calories ?? this.calories,
      sleepDuration: sleepDuration == _sentinel
          ? this.sleepDuration
          : sleepDuration as int?,
      photoPath: photoPath == _sentinel ? this.photoPath : photoPath as String?,
      calorieEntries: calorieEntries == _sentinel
          ? this.calorieEntries
          : calorieEntries as List<CalorieEntry>?,
      neck: neck == _sentinel ? this.neck : neck as double?,
      waist: waist == _sentinel ? this.waist : waist as double?,
    );
  }
}

const _sentinel = Object();
