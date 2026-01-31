import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/models.dart';
import '../services/hive_service.dart';
import 'package:uuid/uuid.dart';

part 'workout_provider.g.dart';

final _uuid = Uuid();

@riverpod
class WorkoutDaysNotifier extends _$WorkoutDaysNotifier {
  @override
  List<WorkoutDay> build() {
    return HiveService.workoutDays.values.toList();
  }

  Future<void> addWorkoutDay(String name) async {
    final day = WorkoutDay(
      id: _uuid.v4(),
      name: name,
      exercises: [],
    );
    await HiveService.workoutDays.put(day.id, day);
    state = HiveService.workoutDays.values.toList();
  }

  Future<void> updateWorkoutDay(String id, String newName) async {
    final day = HiveService.workoutDays.get(id);
    if (day != null) {
      day.name = newName;
      await day.save();
      state = HiveService.workoutDays.values.toList();
    }
  }

  Future<void> deleteWorkoutDay(String id) async {
    await HiveService.workoutDays.delete(id);
    state = HiveService.workoutDays.values.toList();
  }

  Future<void> addExercise(String workoutDayId, Exercise exercise) async {
    final day = HiveService.workoutDays.get(workoutDayId);
    if (day != null) {
      day.exercises.add(exercise);
      await day.save();
      state = HiveService.workoutDays.values.toList();
    }
  }

  Future<void> updateExercise(
    String workoutDayId,
    String exerciseId, {
    String? name,
    int? sets,
    String? details,
  }) async {
    final day = HiveService.workoutDays.get(workoutDayId);
    if (day != null) {
      final index = day.exercises.indexWhere((e) => e.id == exerciseId);
      if (index != -1) {
        final exercise = day.exercises[index];
        exercise.name = name ?? exercise.name;
        exercise.sets = sets ?? exercise.sets;
        exercise.details = details ?? exercise.details;
        await day.save();
        state = HiveService.workoutDays.values.toList();
      }
    }
  }

  Future<void> deleteExercise(String workoutDayId, String exerciseId) async {
    final day = HiveService.workoutDays.get(workoutDayId);
    if (day != null) {
      day.exercises.removeWhere((e) => e.id == exerciseId);
      await day.save();
      state = HiveService.workoutDays.values.toList();
    }
  }
}

@riverpod
class CompletedWorkoutsNotifier extends _$CompletedWorkoutsNotifier {
  @override
  List<CompletedWorkout> build() {
    final workouts = HiveService.completedWorkouts.values.toList();
    workouts.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return workouts;
  }

  Future<void> addCompletedWorkout(CompletedWorkout workout) async {
    await HiveService.completedWorkouts.put(workout.id, workout);
    state = HiveService.completedWorkouts.values.toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  }

  Future<void> deleteCompletedWorkout(String id) async {
    await HiveService.completedWorkouts.delete(id);
    state = HiveService.completedWorkouts.values.toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  }
}
