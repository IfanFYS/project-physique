import 'package:hive/hive.dart';
import 'exercise.dart';

part 'workout_day.g.dart';

@HiveType(typeId: 1)
class WorkoutDay extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late List<Exercise> exercises;

  WorkoutDay({
    required this.id,
    required this.name,
    required this.exercises,
  });

  WorkoutDay copyWith({
    String? id,
    String? name,
    List<Exercise>? exercises,
  }) {
    return WorkoutDay(
      id: id ?? this.id,
      name: name ?? this.name,
      exercises: exercises ?? this.exercises,
    );
  }
}
