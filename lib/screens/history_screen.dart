import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../providers/providers.dart';
import '../models/models.dart';
import '../utils/theme.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedWorkouts = ref.watch(completedWorkoutsNotifierProvider);
    final allLogs = ref.watch(allDailyLogsProvider);
    final userStats = ref.watch(userStatsNotifierProvider);

    // Grouping logic: Get all unique dates from both sources
    final allDates = <String>{
      ...completedWorkouts.map((w) => w.date),
      ...allLogs.map((l) => l.date),
    }.toList()..sort((a, b) => b.compareTo(a));

    // For UI checking, if empty, show some dummy dates
    final displayDates = allDates.isEmpty
        ? ['2026-02-02', '2026-02-01', '2026-01-31']
        : allDates;

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          if (allDates.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => _showClearAllConfirmation(context, ref),
            ),
        ],
      ),
      body: allDates.isEmpty && displayDates.isEmpty
          ? _buildEmptyState(context, ref)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: displayDates.length,
              itemBuilder: (context, index) {
                final dateStr = displayDates[index];

                // Real data or dummy data for UI testing
                final dayWorkouts = completedWorkouts
                    .where((w) => w.date == dateStr)
                    .toList();
                final dayLog = allLogs.firstWhere(
                  (l) => l.date == dateStr,
                  orElse: () => _getDummyLog(dateStr),
                );

                // If it's dummy data, add a dummy workout if none exist
                final workoutsToDisplay =
                    (allDates.isEmpty && dayWorkouts.isEmpty)
                    ? [_getDummyWorkout(dateStr)]
                    : dayWorkouts;

                return _buildDaySection(
                  context,
                  ref,
                  dateStr,
                  workoutsToDisplay,
                  dayLog,
                  userStats,
                );
              },
            ),
    );
  }

  DailyLog _getDummyLog(String date) {
    return DailyLog(
      date: date,
      weight: 75.5,
      calories: 2150,
      sleepDuration: 450,
      neck: 38.0,
      waist: 84.5,
    );
  }

  CompletedWorkout _getDummyWorkout(String date) {
    return CompletedWorkout(
      id: 'dummy',
      date: date,
      workoutDayId: 'dummy',
      workoutDayName: 'Upper Body Power',
      exercises: [
        CompletedExercise(
          exerciseId: '1',
          name: 'Bench Press',
          targetSets: 3,
          details: '60kg',
          actualSets: ['10', '10', '8'],
        ),
        CompletedExercise(
          exerciseId: '2',
          name: 'Pull Ups',
          targetSets: 3,
          details: 'Bodyweight',
          actualSets: ['12', '10', '9'],
        ),
      ],
      completedAt: DateTime.parse('$date 18:30:00'),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No History Yet',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Keep tracking to see your journey here',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildDaySection(
    BuildContext context,
    WidgetRef ref,
    String dateStr,
    List<CompletedWorkout> workouts,
    DailyLog log,
    UserStats stats,
  ) {
    final date = DateTime.tryParse(dateStr) ?? DateTime.now();
    final isToday = DateFormat('yyyy-MM-dd').format(DateTime.now()) == dateStr;
    final dayLabel = isToday
        ? 'Today'
        : DateFormat('EEEE, dd/MM/yyyy').format(date);

    // Calculate BMI and Body Fat
    double? bmi;
    double? bodyFat;

    // Use stats for height if missing
    final height = stats.height ?? 175.0; // Default dummy height if none

    if (log.weight != null && height > 0) {
      bmi = log.weight! / ((height / 100) * (height / 100));

      final neck = log.neck ?? stats.neck;
      final waist = log.waist ?? stats.waist;
      if (neck != null &&
          waist != null &&
          waist > neck &&
          neck > 0 &&
          height > 0) {
        final log10waistNeck = math.log(waist - neck) / math.ln10;
        final log10height = math.log(height) / math.ln10;
        bodyFat =
            495 / (1.0324 - 0.19077 * log10waistNeck + 0.15456 * log10height) -
            450;
        bodyFat = bodyFat.clamp(0, 100);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8, left: 12),
          child: Text(
            dayLabel,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Metrics Overview
                IntrinsicHeight(
                  child: Row(
                    children: [
                      _buildMiniMetric(
                        context,
                        'Weight',
                        log.weight != null
                            ? '${log.weight!.toStringAsFixed(1)}kg'
                            : '-',
                      ),
                      const VerticalDivider(),
                      _buildMiniMetric(
                        context,
                        'Calories',
                        '${log.calories}kcal',
                      ),
                      const VerticalDivider(),
                      _buildMiniMetric(
                        context,
                        'Sleep',
                        log.sleepDuration != null
                            ? '${log.sleepDuration! ~/ 60}h ${log.sleepDuration! % 60}m'
                            : '-',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      _buildMiniMetric(
                        context,
                        'BMI',
                        bmi?.toStringAsFixed(1) ?? '-',
                      ),
                      const VerticalDivider(),
                      _buildMiniMetric(
                        context,
                        'BFP',
                        bodyFat != null
                            ? '${bodyFat.toStringAsFixed(1)}%'
                            : '-',
                      ),
                      const VerticalDivider(),
                      _buildMiniMetric(
                        context,
                        'Neck/Waist',
                        '${log.neck ?? "-"} / ${log.waist ?? "-"} cm',
                      ),
                    ],
                  ),
                ),

                if (workouts.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(),
                  ),
                  Text(
                    'Workouts Completed',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...workouts.map(
                    (w) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: const Icon(
                        Icons.check_circle,
                        color: AppTheme.successColor,
                        size: 20,
                      ),
                      title: Text(
                        w.workoutDayName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${w.exercises.length} exercises • ${DateFormat('HH:mm').format(w.completedAt)}',
                      ),
                      trailing: w.id != 'dummy'
                          ? IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: AppTheme.errorColor,
                              ),
                              onPressed: () =>
                                  _showDeleteConfirmation(context, ref, w),
                            )
                          : null,
                      onTap: () => _showWorkoutDetails(context, w),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniMetric(BuildContext context, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showWorkoutDetails(BuildContext context, CompletedWorkout workout) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, controller) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        workout.workoutDayName,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    padding: const EdgeInsets.all(16),
                    itemCount: workout.exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = workout.exercises[index];
                      return _buildExerciseDetailCard(
                        context,
                        exercise,
                        index + 1,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildExerciseDetailCard(
    BuildContext context,
    CompletedExercise exercise,
    int number,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(
                    '$number',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    exercise.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Target: ${exercise.targetSets} sets - ${exercise.details}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Completed Sets:',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: exercise.actualSets.asMap().entries.map((entry) {
                return Chip(
                  label: Text(
                    'Set ${entry.key + 1}: ${entry.value}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: AppTheme.successColor.withOpacity(0.1),
                  side: BorderSide.none,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    CompletedWorkout workout,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout'),
        content: Text('Delete record for "${workout.workoutDayName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(completedWorkoutsNotifierProvider.notifier)
                  .deleteCompletedWorkout(workout.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showClearAllConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Delete all workout history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final workouts = ref.read(completedWorkoutsNotifierProvider);
              for (final workout in workouts) {
                ref
                    .read(completedWorkoutsNotifierProvider.notifier)
                    .deleteCompletedWorkout(workout.id);
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
