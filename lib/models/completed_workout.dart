import 'package:hive/hive.dart';

part 'completed_workout.g.dart';

@HiveType(typeId: 4)
class CompletedWorkout extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String date;

  @HiveField(2)
  late String workoutDayId;

  @HiveField(3)
  late String workoutDayName;

  @HiveField(4)
  late List<CompletedExercise> exercises;

  @HiveField(5)
  late DateTime completedAt;

  CompletedWorkout({
    required this.id,
    required this.date,
    required this.workoutDayId,
    required this.workoutDayName,
    required this.exercises,
    required this.completedAt,
  });
}

@HiveType(typeId: 5)
class CompletedExercise extends HiveObject {
  @HiveField(0)
  late String exerciseId;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late int targetSets;

  @HiveField(3)
  late String details;

  @HiveField(4)
  late List<String> actualSets;

  CompletedExercise({
    required this.exerciseId,
    required this.name,
    required this.targetSets,
    required this.details,
    required this.actualSets,
  });
}
