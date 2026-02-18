import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../providers/providers.dart';
import '../models/models.dart';
import '../utils/theme.dart';
import '../widgets/sleep_mode_overlay.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  DateTime _selectedDate = DateTime.now();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final todayLog = ref.watch(dailyLogNotifierProvider(dateString));
    final userStats = ref.watch(userStatsNotifierProvider);
    final workoutDays = ref.watch(workoutDaysNotifierProvider);
    final allCompleted = ref.watch(completedWorkoutsNotifierProvider);
    final todaysWorkouts = allCompleted
        .where((w) => w.date == dateString)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Physique Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2024),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() {
                  _selectedDate = date;
                });
              }
            },
          ),
          IconButton(
            icon: Icon(
              ref.watch(sleepModeNotifierProvider).isActive
                  ? Icons.nightlight
                  : Icons.nightlight_outlined,
            ),
            onPressed: () {
              if (ref.read(sleepModeNotifierProvider).isActive) {
                _showWakeUpDialog(context, ref);
              } else {
                ref.read(sleepModeNotifierProvider.notifier).startSleep();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sleep mode activated. Sweet dreams!'),
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _showNameEditDialog(context, ref, userStats),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                    ),
                    Text(
                      '${userStats.name ?? "Strong User"}!',
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildStatsSection(context, ref, todayLog, userStats),
              const SizedBox(height: 24),
              _buildCalorieTracker(context, ref, todayLog),
              const SizedBox(height: 24),
              _buildSleepTracker(context, ref, todayLog),
              const SizedBox(height: 24),
              _buildWorkoutSection(context, ref, todaysWorkouts, workoutDays),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(
    BuildContext context,
    WidgetRef ref,
    DailyLog log,
    UserStats stats,
  ) {
    final todayString = DateFormat('yyyy-MM-dd').format(_selectedDate);

    // Calculate BMI and Body Fat
    final weight = log.weight ?? 0;
    final height = stats.height ?? 0;
    final neck = log.neck ?? stats.neck ?? 0;
    final waist = log.waist ?? stats.waist ?? 0;

    double? bmi;
    double? bodyFat;

    if (weight > 0 && height > 0) {
      bmi = weight / ((height / 100) * (height / 100));
    }

    if (weight > 0 && height > 0 && neck > 0 && waist > 0 && waist > neck) {
      final log10waistNeck = math.log(waist - neck) / math.log(10);
      final log10height = math.log(height) / math.log(10);
      bodyFat =
          495 / (1.0324 - 0.19077 * log10waistNeck + 0.15456 * log10height) -
          450;
      bodyFat = bodyFat.clamp(0, 100);
    }

    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s Measurements',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMeasurementInput(
                      context,
                      label: 'Weight',
                      value: weight > 0 ? weight.toStringAsFixed(1) : '--',
                      unit: 'kg',
                      icon: Icons.monitor_weight_outlined,
                      color: AppTheme.primaryColor,
                      onTap: () =>
                          _showWeightEditDialog(context, ref, log, todayString),
                    ),
                    _buildMeasurementInput(
                      context,
                      label: 'Neck',
                      value: neck > 0 ? neck.toStringAsFixed(1) : '--',
                      unit: 'cm',
                      icon: Icons.straighten,
                      color: Colors.orange,
                      onTap: () =>
                          _showNeckEditDialog(context, ref, log, todayString),
                    ),
                    _buildMeasurementInput(
                      context,
                      label: 'Waist',
                      value: waist > 0 ? waist.toStringAsFixed(1) : '--',
                      unit: 'cm',
                      icon: Icons.straighten,
                      color: Colors.blue,
                      onTap: () =>
                          _showWaistEditDialog(context, ref, log, todayString),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              context,
              icon: Icons.height,
              title: 'Height',
              value: height > 0
                  ? '${height.toStringAsFixed(1)} cm'
                  : 'Tap to set',
              color: AppTheme.successColor,
              onTap: () => _showHeightEditDialog(context, ref, stats),
            ),
            _buildStatCard(
              context,
              icon: Icons.person_outline,
              title: 'Name',
              value: stats.name ?? 'Guest',
              color: Colors.purple,
              onTap: () => _showNameEditDialog(context, ref, stats),
            ),
            _buildStatCard(
              context,
              icon: Icons.accessibility,
              title: 'BMI',
              value: bmi?.toStringAsFixed(1) ?? '--',
              color: bmi != null ? AppTheme.warningColor : Colors.grey,
            ),
            _buildStatCard(
              context,
              icon: Icons.pie_chart_outline,
              title: 'Body Fat',
              value: bodyFat != null ? '${bodyFat.toStringAsFixed(1)}%' : '--',
              color: bodyFat != null ? AppTheme.errorColor : Colors.grey,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMeasurementInput(
    BuildContext context, {
    required String label,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (value != '--')
                  Text(' $unit', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    VoidCallback? onTap,
  }) {
    final card = Card(
      elevation: 0,
      color: color.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: color.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: card,
      );
    }
    return card;
  }

  Widget _buildCalorieTracker(
    BuildContext context,
    WidgetRef ref,
    DailyLog log,
  ) {
    final calorieController = TextEditingController();
    final todayString = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final isStaticDay =
        todayString != DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_fire_department, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      'Calories',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
                Text(
                  '${log.calories} kcal',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: calorieController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Add calories',
                      prefixIcon: Icon(Icons.add),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    final calories = int.tryParse(calorieController.text);
                    if (calories != null && calories > 0) {
                      ref
                          .read(dailyLogNotifierProvider(todayString).notifier)
                          .addCalories(calories);
                      calorieController.clear();
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
            if (log.calorieEntries != null &&
                log.calorieEntries!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text('Entries', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: log.calorieEntries!.length,
                itemBuilder: (context, index) {
                  final entry = log.calorieEntries![index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text('${entry.amount} kcal'),
                    subtitle: Text(DateFormat('HH:mm').format(entry.timestamp)),
                    trailing: !isStaticDay
                        ? IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            onPressed: () {
                              ref
                                  .read(
                                    dailyLogNotifierProvider(
                                      todayString,
                                    ).notifier,
                                  )
                                  .removeCalorieEntry(index);
                            },
                          )
                        : null,
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSleepTracker(BuildContext context, WidgetRef ref, DailyLog log) {
    final sleepHours = log.sleepDuration != null ? log.sleepDuration! ~/ 60 : 0;
    final sleepMinutes = log.sleepDuration != null
        ? log.sleepDuration! % 60
        : 0;
    final isSleepMode = ref.watch(sleepModeNotifierProvider).isActive;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.bedtime, color: Colors.indigo),
                    const SizedBox(width: 8),
                    Text(
                      'Sleep',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (isSleepMode) {
                      _showWakeUpDialog(context, ref);
                    } else {
                      ref.read(sleepModeNotifierProvider.notifier).startSleep();
                    }
                  },
                  icon: Icon(
                    isSleepMode ? Icons.wb_sunny : Icons.nightlight_round,
                  ),
                  label: Text(isSleepMode ? 'Wake Up' : 'Go to Sleep'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSleepMode
                        ? Colors.orange
                        : Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSleepMetric(
                  context,
                  value: sleepHours.toString().padLeft(2, '0'),
                  label: 'Hours',
                ),
                Text(':', style: Theme.of(context).textTheme.displayMedium),
                _buildSleepMetric(
                  context,
                  value: sleepMinutes.toString().padLeft(2, '0'),
                  label: 'Minutes',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepMetric(
    BuildContext context, {
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildWorkoutSection(
    BuildContext context,
    WidgetRef ref,
    List<CompletedWorkout> completed,
    List<WorkoutDay> plans,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.fitness_center, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Workouts',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showWorkoutSelectionDialog(context, plans),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start'),
                ),
              ],
            ),
            if (completed.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Completed Today',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: completed.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final workout = completed[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: Icon(
                      Icons.check_circle,
                      color: AppTheme.successColor,
                      size: 20,
                    ),
                    title: Text(workout.workoutDayName),
                    trailing: Text(
                      DateFormat('HH:mm').format(workout.completedAt),
                    ),
                  );
                },
              ),
            ] else ...[
              const SizedBox(height: 12),
              Text(
                plans.isEmpty
                    ? 'No plans found. Create one in the Workouts tab!'
                    : 'Ready for a workout?',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showWorkoutSelectionDialog(
    BuildContext context,
    List<WorkoutDay> plans,
  ) {
    if (plans.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please create a workout plan first')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose a Workout'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final day = plans[index];
              return ListTile(
                leading: const Icon(Icons.fitness_center),
                title: Text(day.name),
                onTap: () {
                  Navigator.pop(context);
                  _showWorkoutCompletionDialog(context, day);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showWorkoutCompletionDialog(BuildContext context, WorkoutDay day) {
    final Map<String, List<String>> actualSets = {};
    for (var ex in day.exercises) {
      actualSets[ex.id] = List.generate(ex.sets, (index) => '');
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Complete ${day.name}'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: day.exercises.map((ex) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          ex.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ...List.generate(ex.sets, (sIdx) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Set ${sIdx + 1} (reps/weight)',
                              hintText: ex.details,
                            ),
                            onChanged: (val) => actualSets[ex.id]![sIdx] = val,
                          ),
                        );
                      }),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final completedExercises = day.exercises.map((ex) {
                  return CompletedExercise(
                    exerciseId: ex.id,
                    name: ex.name,
                    targetSets: ex.sets,
                    details: ex.details,
                    actualSets: actualSets[ex.id]!,
                  );
                }).toList();

                final completedWorkout = CompletedWorkout(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  date: DateFormat('yyyy-MM-dd').format(_selectedDate),
                  workoutDayId: day.id,
                  workoutDayName: day.name,
                  exercises: completedExercises,
                  completedAt: DateTime.now(),
                );

                ref
                    .read(completedWorkoutsNotifierProvider.notifier)
                    .addCompletedWorkout(completedWorkout);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Workout logged!')),
                );
              },
              child: const Text('Complete'),
            ),
          ],
        ),
      ),
    );
  }

  void _showWeightEditDialog(
    BuildContext context,
    WidgetRef ref,
    DailyLog log,
    String date,
  ) {
    final controller = TextEditingController(
      text: log.weight?.toString() ?? '',
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Weight'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'kg'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null) {
                ref
                    .read(dailyLogNotifierProvider(date).notifier)
                    .updateWeight(val);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showHeightEditDialog(
    BuildContext context,
    WidgetRef ref,
    UserStats stats,
  ) {
    final controller = TextEditingController(
      text: stats.height?.toString() ?? '',
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Height'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'cm'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null) {
                ref.read(userStatsNotifierProvider.notifier).updateHeight(val);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showNeckEditDialog(
    BuildContext context,
    WidgetRef ref,
    DailyLog log,
    String date,
  ) {
    final controller = TextEditingController(text: log.neck?.toString() ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Neck Circumference'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'cm'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null) {
                ref
                    .read(dailyLogNotifierProvider(date).notifier)
                    .updateNeck(val);
                ref.read(userStatsNotifierProvider.notifier).updateNeck(val);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showWaistEditDialog(
    BuildContext context,
    WidgetRef ref,
    DailyLog log,
    String date,
  ) {
    final controller = TextEditingController(text: log.waist?.toString() ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Waist Circumference'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'cm'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null) {
                ref
                    .read(dailyLogNotifierProvider(date).notifier)
                    .updateWaist(val);
                ref.read(userStatsNotifierProvider.notifier).updateWaist(val);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showNameEditDialog(
    BuildContext context,
    WidgetRef ref,
    UserStats stats,
  ) {
    final controller = TextEditingController(text: stats.name ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Name'),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(userStatsNotifierProvider.notifier)
                  .updateName(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showWakeUpDialog(BuildContext context, WidgetRef ref) async {
    final duration = ref.read(sleepModeNotifierProvider.notifier).endSleep();
    if (duration != null) {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await ref
          .read(dailyLogNotifierProvider(today).notifier)
          .setSleepDuration(duration);
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Good Morning!'),
            content: Text(
              'You slept for ${duration ~/ 60}h ${duration % 60}m.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
}
