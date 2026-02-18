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
    double? weight,
    int? calories,
    int? sleepDuration,
    String? photoPath,
    List<CalorieEntry>? calorieEntries,
    double? neck,
    double? waist,
  }) {
    return DailyLog(
      date: date ?? this.date,
      weight: weight ?? this.weight,
      calories: calories ?? this.calories,
      sleepDuration: sleepDuration ?? this.sleepDuration,
      photoPath: photoPath ?? this.photoPath,
      calorieEntries: calorieEntries ?? this.calorieEntries,
      neck: neck ?? this.neck,
      waist: waist ?? this.waist,
    );
  }
}
