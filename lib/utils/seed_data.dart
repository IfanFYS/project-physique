import '../models/models.dart';
import 'package:uuid/uuid.dart';

class SeedData {
  static final _uuid = Uuid();

  static List<WorkoutDay> getInitialWorkoutDays() {
    return [
      _createDay1(),
      _createDay2(),
      _createDay3(),
      _createDay4(),
      _createDay5(),
    ];
  }

  static WorkoutDay _createDay1() {
    return WorkoutDay(
      id: _uuid.v4(),
      name: 'Heavy Push',
      exercises: [
        Exercise(id: _uuid.v4(), name: 'Pec Fly', sets: 3, details: '45kg'),
        Exercise(id: _uuid.v4(), name: 'Incline Bench', sets: 4, details: '36kg'),
        Exercise(id: _uuid.v4(), name: 'Seated Shoulder Press', sets: 3, details: '28kg'),
        Exercise(id: _uuid.v4(), name: 'Tricep Rope', sets: 3, details: '24kg'),
        Exercise(id: _uuid.v4(), name: 'Plank', sets: 3, details: '120s'),
      ],
    );
  }

  static WorkoutDay _createDay2() {
    return WorkoutDay(
      id: _uuid.v4(),
      name: 'Heavy Pull',
      exercises: [
        Exercise(id: _uuid.v4(), name: 'Lat Pulldowns', sets: 3, details: '51kg'),
        Exercise(id: _uuid.v4(), name: 'Seated Cable Row', sets: 3, details: '42kg'),
        Exercise(id: _uuid.v4(), name: 'Bicep Curls', sets: 3, details: '30kg'),
        Exercise(id: _uuid.v4(), name: 'Hammer Curls', sets: 3, details: '16kg'),
        Exercise(id: _uuid.v4(), name: 'Leg Raises', sets: 3, details: '10-12'),
      ],
    );
  }

  static WorkoutDay _createDay3() {
    return WorkoutDay(
      id: _uuid.v4(),
      name: 'Glow Up',
      exercises: [
        Exercise(id: _uuid.v4(), name: 'Lateral Raises', sets: 3, details: '10kg'),
        Exercise(id: _uuid.v4(), name: 'Skullcrushers', sets: 3, details: '28kg'),
        Exercise(id: _uuid.v4(), name: 'Tricep Rope', sets: 3, details: '24kg'),
        Exercise(id: _uuid.v4(), name: 'Reverse Curls', sets: 3, details: '30kg'),
        Exercise(id: _uuid.v4(), name: 'Wrist Curls', sets: 3, details: ''),
      ],
    );
  }

  static WorkoutDay _createDay4() {
    return WorkoutDay(
      id: _uuid.v4(),
      name: 'Chest Hypertrophy',
      exercises: [
        Exercise(id: _uuid.v4(), name: 'Incline Smith', sets: 4, details: '45kg'),
        Exercise(id: _uuid.v4(), name: 'Pec Fly', sets: 3, details: '45kg'),
        Exercise(id: _uuid.v4(), name: 'Chest Dips', sets: 3, details: 'Fail'),
        Exercise(id: _uuid.v4(), name: 'Lateral Raises', sets: 3, details: '20kg'),
        Exercise(id: _uuid.v4(), name: 'Tricep Rope', sets: 3, details: '24kg'),
      ],
    );
  }

  static WorkoutDay _createDay5() {
    return WorkoutDay(
      id: _uuid.v4(),
      name: 'Volume',
      exercises: [
        Exercise(id: _uuid.v4(), name: 'Lat Pulldowns', sets: 4, details: '51kg'),
        Exercise(id: _uuid.v4(), name: 'Seated Cable Row', sets: 3, details: '42kg'),
        Exercise(id: _uuid.v4(), name: 'Bicep Curls', sets: 3, details: '30kg'),
        Exercise(id: _uuid.v4(), name: 'Hammer Curls', sets: 3, details: '16kg'),
        Exercise(id: _uuid.v4(), name: 'Wrist Curls', sets: 3, details: ''),
        Exercise(id: _uuid.v4(), name: 'Leg Raises', sets: 3, details: '10-12'),
      ],
    );
  }
}
