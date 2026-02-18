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

  // Generate dummy daily logs for the past 14 days
  static List<DailyLog> getDummyDailyLogs() {
    final logs = <DailyLog>[];
    final now = DateTime.now();

    for (int i = 13; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateString =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      // Vary the data to make it realistic
      final baseWeight = 75.0;
      final weightVariation = (i % 3) * 0.2 - 0.2; // Small weight fluctuations
      final baseNeck = 38.0;
      final baseWaist = 85.0;

      logs.add(
        DailyLog(
          date: dateString,
          weight: baseWeight + weightVariation,
          calories: 1800 + (i % 5) * 150 + (i % 2) * 100, // 1800-2450 calories
          sleepDuration: 420 + (i % 4) * 30 - (i % 3) * 15, // 6.5-8 hours sleep
          neck: baseNeck + (i % 2 == 0 ? 0.1 : -0.1),
          waist:
              baseWaist -
              (13 - i) * 0.2 +
              (i % 3) * 0.1, // Gradual waist decrease
        ),
      );
    }

    return logs;
  }

  // Generate dummy completed workouts for the past 14 days
  static List<CompletedWorkout> getDummyCompletedWorkouts(
    List<WorkoutDay> workoutDays,
  ) {
    final workouts = <CompletedWorkout>[];
    final now = DateTime.now();

    // Workout pattern: Day 1, Day 2, Rest, Day 3, Day 4, Rest, Day 5, Rest, repeat
    final workoutPattern = [0, 1, -1, 2, 3, -1, 4, -1];

    for (int i = 13; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateString =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      // Determine if this day should have a workout
      final patternIndex = (13 - i) % workoutPattern.length;
      final workoutDayIndex = workoutPattern[patternIndex];

      if (workoutDayIndex >= 0 && workoutDayIndex < workoutDays.length) {
        final workoutDay = workoutDays[workoutDayIndex];

        workouts.add(
          CompletedWorkout(
            id: _uuid.v4(),
            date: dateString,
            workoutDayId: workoutDay.id,
            workoutDayName: workoutDay.name,
            exercises: workoutDay.exercises
                .map(
                  (e) => CompletedExercise(
                    exerciseId: e.id,
                    name: e.name,
                    targetSets: e.sets,
                    details: e.details,
                    actualSets: List.generate(
                      e.sets,
                      (index) => '${10 + (index % 3)}',
                    ),
                  ),
                )
                .toList(),
            completedAt: date.add(
              Duration(hours: 18 + (i % 3)),
            ), // Evening workouts
          ),
        );
      }
    }

    return workouts;
  }

  static WorkoutDay _createDay1() {
    return WorkoutDay(
      id: _uuid.v4(),
      name: 'Heavy Push',
      exercises: [
        Exercise(id: _uuid.v4(), name: 'Pec Fly', sets: 3, details: '45kg'),
        Exercise(
          id: _uuid.v4(),
          name: 'Incline Bench',
          sets: 4,
          details: '36kg',
        ),
        Exercise(
          id: _uuid.v4(),
          name: 'Seated Shoulder Press',
          sets: 3,
          details: '28kg',
        ),
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
        Exercise(
          id: _uuid.v4(),
          name: 'Lat Pulldowns',
          sets: 3,
          details: '51kg',
        ),
        Exercise(
          id: _uuid.v4(),
          name: 'Seated Cable Row',
          sets: 3,
          details: '42kg',
        ),
        Exercise(id: _uuid.v4(), name: 'Bicep Curls', sets: 3, details: '30kg'),
        Exercise(
          id: _uuid.v4(),
          name: 'Hammer Curls',
          sets: 3,
          details: '16kg',
        ),
        Exercise(id: _uuid.v4(), name: 'Leg Raises', sets: 3, details: '10-12'),
      ],
    );
  }

  static WorkoutDay _createDay3() {
    return WorkoutDay(
      id: _uuid.v4(),
      name: 'Glow Up',
      exercises: [
        Exercise(
          id: _uuid.v4(),
          name: 'Lateral Raises',
          sets: 3,
          details: '10kg',
        ),
        Exercise(
          id: _uuid.v4(),
          name: 'Skullcrushers',
          sets: 3,
          details: '28kg',
        ),
        Exercise(id: _uuid.v4(), name: 'Tricep Rope', sets: 3, details: '24kg'),
        Exercise(
          id: _uuid.v4(),
          name: 'Reverse Curls',
          sets: 3,
          details: '30kg',
        ),
        Exercise(id: _uuid.v4(), name: 'Wrist Curls', sets: 3, details: ''),
      ],
    );
  }

  static WorkoutDay _createDay4() {
    return WorkoutDay(
      id: _uuid.v4(),
      name: 'Chest Hypertrophy',
      exercises: [
        Exercise(
          id: _uuid.v4(),
          name: 'Incline Smith',
          sets: 4,
          details: '45kg',
        ),
        Exercise(id: _uuid.v4(), name: 'Pec Fly', sets: 3, details: '45kg'),
        Exercise(id: _uuid.v4(), name: 'Chest Dips', sets: 3, details: 'Fail'),
        Exercise(
          id: _uuid.v4(),
          name: 'Lateral Raises',
          sets: 3,
          details: '20kg',
        ),
        Exercise(id: _uuid.v4(), name: 'Tricep Rope', sets: 3, details: '24kg'),
      ],
    );
  }

  static WorkoutDay _createDay5() {
    return WorkoutDay(
      id: _uuid.v4(),
      name: 'Volume',
      exercises: [
        Exercise(
          id: _uuid.v4(),
          name: 'Lat Pulldowns',
          sets: 4,
          details: '51kg',
        ),
        Exercise(
          id: _uuid.v4(),
          name: 'Seated Cable Row',
          sets: 3,
          details: '42kg',
        ),
        Exercise(id: _uuid.v4(), name: 'Bicep Curls', sets: 3, details: '30kg'),
        Exercise(
          id: _uuid.v4(),
          name: 'Hammer Curls',
          sets: 3,
          details: '16kg',
        ),
        Exercise(id: _uuid.v4(), name: 'Wrist Curls', sets: 3, details: ''),
        Exercise(id: _uuid.v4(), name: 'Leg Raises', sets: 3, details: '10-12'),
      ],
    );
  }
}
