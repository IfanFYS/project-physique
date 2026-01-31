import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../utils/theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _testingMode = false;
  DateTime _testDate = DateTime.now();

  String _getGreeting() {
    final hour = _testingMode ? _testDate.hour : DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final todayLog = ref.watch(todayLogProvider);
    final userStats = ref.watch(userStatsNotifierProvider);
    final workoutDays = ref.watch(workoutDaysNotifierProvider);
    final completedWorkouts = ref.watch(completedWorkoutsNotifierProvider);
    final sleepMode = ref.watch(sleepModeNotifierProvider);
    
    final today = _testingMode ? _testDate : DateTime.now();
    final todayString = DateFormat('yyyy-MM-dd').format(today);
    final todaysWorkouts = completedWorkouts.where((w) => w.date == todayString).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Physique'),
        actions: [
          // Testing Mode Button
          IconButton(
            icon: Icon(
              Icons.bug_report,
              color: _testingMode ? Colors.orange : null,
            ),
            onPressed: () => _showTestingDialog(context, ref, todayString),
            tooltip: 'Testing Mode',
          ),
          IconButton(
            icon: Icon(
              sleepMode.isActive ? Icons.nightlight_round : Icons.nightlight_outlined,
              color: sleepMode.isActive ? AppTheme.accentColor : null,
            ),
            onPressed: () {
              if (sleepMode.isActive) {
                final duration = ref.read(sleepModeNotifierProvider.notifier).endSleep();
                if (duration != null) {
                  ref.read(dailyLogNotifierProvider(todayString).notifier).setSleepDuration(duration);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sleep recorded: ${duration ~/ 60}h ${duration % 60}m')),
                  );
                }
              } else {
                ref.read(sleepModeNotifierProvider.notifier).startSleep();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sleep mode activated. Sweet dreams!')),
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
              Text(
                '${_getGreeting()},',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 24),
              _buildStatsGrid(context, ref, todayLog, userStats),
              const SizedBox(height: 24),
              _buildMeasurementsCard(context, ref, userStats),
              const SizedBox(height: 24),
              _buildCalorieTracker(context, ref, todayLog),
              const SizedBox(height: 24),
              _buildSleepTracker(context, todayLog),
              const SizedBox(height: 24),
              _buildTodayWorkouts(context, todaysWorkouts),
              const SizedBox(height: 24),
              _buildQuickActions(context, workoutDays),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, WidgetRef ref, DailyLog log, UserStats stats) {
    final today = _testingMode ? _testDate : DateTime.now();
    final todayString = DateFormat('yyyy-MM-dd').format(today);
    
    // Calculate BMI and Body Fat with validation
    double? bmi;
    double? bodyFat;
    
    if (log.weight != null && log.weight! > 0 && stats.height != null && stats.height! > 0) {
      bmi = stats.calculateBMI(log.weight!);
    }
    
    if (log.weight != null && log.weight! > 0 && 
        stats.height != null && stats.height! > 0 &&
        stats.neck != null && stats.neck! > 0 &&
        stats.waist != null && stats.waist! > 0) {
      bodyFat = stats.calculateBodyFat(log.weight!);
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        // Weight Card - Tappable to edit
        _buildStatCard(
          context,
          icon: Icons.monitor_weight_outlined,
          title: 'Weight',
          value: log.weight != null && log.weight! > 0 ? '${log.weight!.toStringAsFixed(1)} kg' : 'Tap to set',
          color: AppTheme.primaryColor,
          onTap: () => _showWeightEditDialog(context, ref, log, todayString),
        ),
        // Height Card - Tappable to edit
        _buildStatCard(
          context,
          icon: Icons.height,
          title: 'Height',
          value: stats.height != null && stats.height! > 0 ? '${stats.height!.toStringAsFixed(1)} cm' : 'Tap to set',
          color: AppTheme.successColor,
          onTap: () => _showHeightEditDialog(context, ref, stats),
        ),
        // BMI Card
        _buildStatCard(
          context,
          icon: Icons.accessibility,
          title: 'BMI',
          value: bmi?.toStringAsFixed(1) ?? 'Need weight & height',
          color: bmi != null ? AppTheme.warningColor : Colors.grey,
        ),
        // Body Fat Card
        _buildStatCard(
          context,
          icon: Icons.percent,
          title: 'Body Fat',
          value: bodyFat != null ? '${bodyFat.toStringAsFixed(1)}%' : 'Need all measurements',
          color: bodyFat != null ? AppTheme.secondaryColor : Colors.grey,
        ),
      ],
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
    Widget card = Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: value.length > 10 ? 14 : null,
              ),
            ),
          ],
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: card,
      );
    }

    return card;
  }

  Widget _buildMeasurementsCard(BuildContext context, WidgetRef ref, UserStats stats) {
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
                    Icon(Icons.straighten, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Body Measurements',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => _showAllMeasurementsDialog(context, ref, stats),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMeasurementItem(
                  context,
                  label: 'Height',
                  value: stats.height != null ? '${stats.height!.toStringAsFixed(1)} cm' : '-',
                  icon: Icons.height,
                ),
                _buildMeasurementItem(
                  context,
                  label: 'Neck',
                  value: stats.neck != null ? '${stats.neck!.toStringAsFixed(1)} cm' : '-',
                  icon: Icons.accessibility,
                ),
                _buildMeasurementItem(
                  context,
                  label: 'Waist',
                  value: stats.waist != null ? '${stats.waist!.toStringAsFixed(1)} cm' : '-',
                  icon: Icons.accessibility_new,
                ),
              ],
            ),
            if (stats.height != null && stats.neck != null && stats.waist != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: AppTheme.successColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'All measurements set! BMI and Body Fat % will be calculated automatically.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.successColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementItem(BuildContext context, {required String label, required String value, required IconData icon}) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildCalorieTracker(BuildContext context, WidgetRef ref, DailyLog log) {
    final calorieController = TextEditingController();

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
                      'Calories Today',
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
                      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
                      ref.read(dailyLogNotifierProvider(today).notifier).addCalories(calories);
                      calorieController.clear();
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepTracker(BuildContext context, DailyLog log) {
    final sleepHours = log.sleepDuration != null ? log.sleepDuration! ~/ 60 : 0;
    final sleepMinutes = log.sleepDuration != null ? log.sleepDuration! % 60 : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bedtime, color: Colors.indigo),
                const SizedBox(width: 8),
                Text(
                  'Sleep Last Night',
                  style: Theme.of(context).textTheme.headlineMedium,
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
                Text(
                  ':',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
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

  Widget _buildSleepMetric(BuildContext context, {required String value, required String label}) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildTodayWorkouts(BuildContext context, List<CompletedWorkout> workouts) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: AppTheme.successColor),
                const SizedBox(width: 8),
                Text(
                  'Completed Today',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (workouts.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No workouts completed today yet.\nGet moving!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: workouts.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final workout = workouts[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: Icon(Icons.fitness_center, color: AppTheme.primaryColor),
                    ),
                    title: Text(workout.workoutDayName),
                    subtitle: Text('${workout.exercises.length} exercises'),
                    trailing: Text(
                      DateFormat('HH:mm').format(workout.completedAt),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, List<WorkoutDay> workoutDays) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Start Workout',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            if (workoutDays.isEmpty)
              Center(
                child: Text(
                  'No workout plans yet. Create one in the Workouts tab!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: workoutDays.take(3).map((day) {
                  return ActionChip(
                    avatar: Icon(Icons.fitness_center, size: 18, color: AppTheme.primaryColor),
                    label: Text(day.name),
                    onPressed: () {
                      _showWorkoutCompletionDialog(context, day);
                    },
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  void _showWorkoutCompletionDialog(BuildContext context, WorkoutDay day) {
    final List<TextEditingController> setControllers = [];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Complete: ${day.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: day.exercises.map((exercise) {
              setControllers.add(TextEditingController());
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Target: ${exercise.sets} sets - ${exercise.details}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: setControllers[day.exercises.indexOf(exercise)],
                      decoration: const InputDecoration(
                        hintText: 'e.g., 10,10,10 (reps per set)',
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Consumer(
            builder: (context, ref, child) {
              return ElevatedButton(
                onPressed: () {
                  final completedExercises = <CompletedExercise>[];
                  for (int i = 0; i < day.exercises.length; i++) {
                    final exercise = day.exercises[i];
                    final setsText = setControllers[i].text;
                    final sets = setsText.isNotEmpty 
                        ? setsText.split(',').map((s) => s.trim()).toList()
                        : List.generate(exercise.sets, (index) => '-');
                    
                    completedExercises.add(CompletedExercise(
                      exerciseId: exercise.id,
                      name: exercise.name,
                      targetSets: exercise.sets,
                      details: exercise.details,
                      actualSets: sets,
                    ));
                  }

                  final completedWorkout = CompletedWorkout(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                    workoutDayId: day.id,
                    workoutDayName: day.name,
                    exercises: completedExercises,
                    completedAt: DateTime.now(),
                  );

                  ref.read(completedWorkoutsNotifierProvider.notifier).addCompletedWorkout(completedWorkout);
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${day.name} completed! Great job!')),
                  );
                },
                child: const Text('Complete'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showTestingDialog(BuildContext context, WidgetRef ref, String todayString) {
    final dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(_testDate),
    );
    final sleepHoursController = TextEditingController(text: '8');
    final sleepMinutesController = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Testing Mode'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Testing Mode Toggle
              Row(
                children: [
                  const Text('Enable Testing:'),
                  Switch(
                    value: _testingMode,
                    onChanged: (value) {
                      setState(() {
                        _testingMode = value;
                      });
                      Navigator.pop(context);
                      _showTestingDialog(context, ref, todayString);
                    },
                  ),
                ],
              ),
              if (_testingMode) ...[
                const Divider(),
                const Text(
                  'Test Date:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    hintText: 'YYYY-MM-DD',
                    helperText: 'Format: 2026-01-31',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Set Sleep Duration:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: sleepHoursController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Hours',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: sleepMinutesController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Minutes',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          if (_testingMode)
            ElevatedButton(
              onPressed: () {
                // Parse and apply test date
                final parts = dateController.text.split('-');
                if (parts.length == 3) {
                  setState(() {
                    _testDate = DateTime(
                      int.parse(parts[0]),
                      int.parse(parts[1]),
                      int.parse(parts[2]),
                    );
                  });
                }

                // Set sleep duration
                final hours = int.tryParse(sleepHoursController.text) ?? 0;
                final minutes = int.tryParse(sleepMinutesController.text) ?? 0;
                final totalMinutes = (hours * 60) + minutes;

                final testDateString = DateFormat('yyyy-MM-dd').format(_testDate);
                ref.read(dailyLogNotifierProvider(testDateString).notifier).setSleepDuration(totalMinutes);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Test settings applied for ${dateController.text}')),
                );
              },
              child: const Text('Apply'),
            ),
        ],
      ),
    );
  }

  void _showWeightEditDialog(BuildContext context, WidgetRef ref, DailyLog log, String todayString) {
    final controller = TextEditingController(
      text: log.weight?.toStringAsFixed(1) ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Weight'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Weight (kg)',
            suffixText: 'kg',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final weight = double.tryParse(controller.text);
              if (weight != null && weight > 0) {
                ref.read(dailyLogNotifierProvider(todayString).notifier).updateWeight(weight);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Weight updated to ${weight.toStringAsFixed(1)} kg')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showHeightEditDialog(BuildContext context, WidgetRef ref, UserStats stats) {
    final controller = TextEditingController(
      text: stats.height?.toStringAsFixed(1) ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Height'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Height (cm)',
            suffixText: 'cm',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final height = double.tryParse(controller.text);
              if (height != null && height > 0) {
                ref.read(userStatsNotifierProvider.notifier).updateHeight(height);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Height updated to ${height.toStringAsFixed(1)} cm')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAllMeasurementsDialog(BuildContext context, WidgetRef ref, UserStats stats) {
    final heightController = TextEditingController(
      text: stats.height?.toStringAsFixed(1) ?? '',
    );
    final neckController = TextEditingController(
      text: stats.neck?.toStringAsFixed(1) ?? '',
    );
    final waistController = TextEditingController(
      text: stats.waist?.toStringAsFixed(1) ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Body Measurements'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: heightController,
                decoration: const InputDecoration(
                  labelText: 'Height (cm)',
                  hintText: 'e.g., 175',
                  suffixText: 'cm',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: neckController,
                decoration: const InputDecoration(
                  labelText: 'Neck Circumference (cm)',
                  hintText: 'e.g., 38',
                  suffixText: 'cm',
                  helperText: 'Measure at narrowest point',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: waistController,
                decoration: const InputDecoration(
                  labelText: 'Waist Circumference (cm)',
                  hintText: 'e.g., 85',
                  suffixText: 'cm',
                  helperText: 'Measure at navel level',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final height = double.tryParse(heightController.text);
              final neck = double.tryParse(neckController.text);
              final waist = double.tryParse(waistController.text);

              if (height != null && height > 0) {
                ref.read(userStatsNotifierProvider.notifier).updateHeight(height);
              }
              if (neck != null && neck > 0) {
                ref.read(userStatsNotifierProvider.notifier).updateNeck(neck);
              }
              if (waist != null && waist > 0) {
                ref.read(userStatsNotifierProvider.notifier).updateWaist(waist);
              }

              Navigator.pop(context);
              
              // Show success message
              final message = <String>[];
              if (height != null && height > 0) message.add('Height');
              if (neck != null && neck > 0) message.add('Neck');
              if (waist != null && waist > 0) message.add('Waist');
              
              if (message.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${message.join(", ")} updated successfully!'),
                  ),
                );
              }
            },
            child: const Text('Save All'),
          ),
        ],
      ),
    );
  }
}
