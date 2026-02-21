import '../models/models.dart';
import 'package:uuid/uuid.dart';

class SeedData {
  static final _uuid = Uuid();

  static List<WorkoutDay> getInitialWorkoutDays() {
    return [
      _createMonday(),
      _createTuesday(),
      _createWednesday(),
      _createThursday(),
      _createFriday(),
    ];
  }

  // Generate dummy daily logs for the past 30 days
  static List<DailyLog> getDummyDailyLogs() {
    final logs = <DailyLog>[];
    final now = DateTime.now();

    for (int i = 29; i >= 0; i--) {
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

  // Generate dummy completed workouts for the past 30 days
  static List<CompletedWorkout> getDummyCompletedWorkouts(
    List<WorkoutDay> workoutDays,
  ) {
    final workouts = <CompletedWorkout>[];
    final now = DateTime.now();

    // Workout pattern: Mon, Tue, Rest, Wed, Thu, Rest, Fri, Rest, repeat
    final workoutPattern = [0, 1, -1, 2, 3, -1, 4, -1];

    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateString =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      // Determine if this day should have a workout
      final patternIndex = (29 - i) % workoutPattern.length;
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

  // Monday - Shoulders & Arms
  static WorkoutDay _createMonday() {
    return WorkoutDay(
      id: _uuid.v4(),
      name: 'Monday — Shoulders & Arms',
      exercises: [
        Exercise(
          id: _uuid.v4(),
          name: 'Lateral Raises',
          sets: 3,
          details: '12–15 reps · 20kg',
        ),
        Exercise(
          id: _uuid.v4(),
          name: 'Normal Bench Press',
          sets: 3,
          details: '6–8 reps · 45kg',
        ),
        Exercise(
          id: _uuid.v4(),
          name: 'Chest Dips',
          sets: 3,
          details: '10–12 reps · bodyweight',
        ),
        Exercise(
          id: _uuid.v4(),
          name: 'Tricep Rope Pushdown',
          sets: 3,
          details: '12–15 reps · 24kg',
        ),
        Exercise(
          id: _uuid.v4(),
          name: 'Hammer Curls',
          sets: 3,
          details: '10–12 reps · 32kg',
        ),
        Exercise(
          id: _uuid.v4(),
          name: 'Wrist Curls',
          sets: 3,
          details: '12–15 reps · 24kg',
        ),
      ],
    );
  }

  // Tuesday - Full Body
  static WorkoutDay _createTuesday() {
    return WorkoutDay(
      id: _uuid.v4(),
      name: 'Tuesday — Full Body',
      exercises: [
        Exercise(
          id: _uuid.v4(),
          name: 'Assisted Pull-ups',
          sets: 3,
          details: '8–10 reps · BW-30kg',
        ),
        Exercise(
          id: _uuid.v4(),
          name: 'Dumbbell Goblet Squats',
          sets: 3,
          details: '10–12 reps · 32kg',
        ),
        Exercise(
          id: _uuid.v4(),
          name: 'Dumbbell Lunges',
          sets: 3,
          details: '10 reps · 32kg',
        ),
        Exercise(
          id: _uuid.v4(),
          name: 'Seated Cable Row',
          sets: 3,
          details: '10–12 reps · 42kg',
        ),
        Exercise(
          id: _uuid.v4(),
          name: 'Pec Fly',
          sets: 3,
          details: '12–15 reps · 42kg',
        ),
        Exercise(
          id: _uuid.v4(),
          name: 'Lateral Raises',
          sets: 3,
          details: '15 reps · 16kg',
        ),
      ],
    );
  }

  // Wednesday - Push
  static WorkoutDay _createWednesday() {
    return WorkoutDay(
      id: _uuid.v4(),
      name: 'Wednesday — Push',
      exercises: [
        Exercise(
          id: _uuid.v4(),
          name: 'Incline Bench Press',
          sets: 3,
          details: '6–8 reps · 45kg',
        ),
        Exercise(
          id: _uuid.v4(),
          name: 'Seated Shoulder Press',
          sets: 3,
          details: '8–10 reps · 25kg',
        ),
        Exercise(
          id: _uuid.v4(),
          name: 'Pec Fly',
          sets: 3,
          details: '12–15 reps · 45kg',
        ),
        Exercise(
          id: _uuid.v4(),
          name: 'Tricep Rope Pushdowns',
          sets: 3,
          details: '12–15 reps · 24kg',
        ),
        Exercise(
          id: _uuid.v4(),
          name: 'Chest Dips',
          sets: 3,
          details: '12–15 reps · bodyweight',
        ),
      ],
    );
  }

  // Thursday - Pull
  static WorkoutDay _createThursday() {
    return WorkoutDay(
      id: _uuid.v4(),
      name: 'Thursday — Pull',
      exercises: [
        Exercise(
          id: _uuid.v4(),
          name: 'Assisted Pull-ups',
          sets: 3,
          details: '8–10 reps · BW-30kg',
        ),
        Exercise(
          id: _uuid.v4(),
          name: 'Seated Cable Row',
          sets: 3,
          details: '10–12 reps · 42kg',
        ),
        Exercise(
          id: _uuid.v4(),
          name: 'Bicep Curls (Normal)',
          sets: 3,
          details: '10–12 reps · 32kg',
        ),
        Exercise(
          id: _uuid.v4(),
          name: 'Skullcrushers',
          sets: 3,
          details: '10–12 reps · 28kg',
        ),
        Exercise(
          id: _uuid.v4(),
          name: 'Wrist Curls',
          sets: 3,
          details: '12–15 reps · 24kg',
        ),
      ],
    );
  }

  // Friday - Legs & Chest
  static WorkoutDay _createFriday() {
    return WorkoutDay(
      id: _uuid.v4(),
      name: 'Friday — Legs & Chest',
      exercises: [
        Exercise(
          id: _uuid.v4(),
          name: 'Dumbbell Goblet Squats',
          sets: 3,
          details: '10–12 reps · 32kg',
        ),
        Exercise(
          id: _uuid.v4(),
          name: 'Dumbbell Lunges',
          sets: 3,
          details: '10 reps/leg · 32kg',
        ),
        Exercise(
          id: _uuid.v4(),
          name: 'Incline Bench Press',
          sets: 4,
          details: '8–10 reps · 45kg',
        ),
        Exercise(
          id: _uuid.v4(),
          name: 'Bicep Curls (Normal)',
          sets: 3,
          details: '10–12 reps · 32kg',
        ),
        Exercise(
          id: _uuid.v4(),
          name: 'Skullcrushers',
          sets: 3,
          details: '10–12 reps · 28kg',
        ),
      ],
    );
  }
}
