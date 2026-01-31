import 'package:hive/hive.dart';

part 'exercise.g.dart';

@HiveType(typeId: 0)
class Exercise extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late int sets;

  @HiveField(3)
  late String details;

  Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.details,
  });

  Exercise copyWith({
    String? id,
    String? name,
    int? sets,
    String? details,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      details: details ?? this.details,
    );
  }
}
