import 'package:hive/hive.dart';

part 'calorie_entry.g.dart';

@HiveType(typeId: 6)
class CalorieEntry extends HiveObject {
  @HiveField(0)
  final int amount;

  @HiveField(1)
  final DateTime timestamp;

  CalorieEntry({required this.amount, required this.timestamp});
}
