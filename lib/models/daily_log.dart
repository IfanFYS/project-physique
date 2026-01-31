import 'package:hive/hive.dart';

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

  DailyLog({
    required this.date,
    this.weight,
    this.calories = 0,
    this.sleepDuration,
    this.photoPath,
  });

  DailyLog copyWith({
    String? date,
    double? weight,
    int? calories,
    int? sleepDuration,
    String? photoPath,
  }) {
    return DailyLog(
      date: date ?? this.date,
      weight: weight ?? this.weight,
      calories: calories ?? this.calories,
      sleepDuration: sleepDuration ?? this.sleepDuration,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}
