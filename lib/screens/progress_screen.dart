import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../utils/theme.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  int _selectedChartIndex = 0;

  @override
  Widget build(BuildContext context) {
    final allLogs = ref.watch(allDailyLogsProvider);
    final userStats = ref.watch(userStatsNotifierProvider);
    final completedWorkouts = ref.watch(completedWorkoutsNotifierProvider);

    final validLogs = allLogs.where((log) => log.weight != null).toList();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditStatsDialog(context, ref, userStats),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatsOverview(context, validLogs, userStats),
              const SizedBox(height: 24),
              _buildChartSelector(),
              const SizedBox(height: 16),
              if (validLogs.length >= 2)
                _buildChart(context, validLogs, completedWorkouts)
              else
                _buildInsufficientDataCard(context),
              const SizedBox(height: 24),
              _buildRecentLogs(context, allLogs),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsOverview(BuildContext context, List<DailyLog> logs, UserStats stats) {
    if (logs.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.monitor_weight_outlined, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                'No weight data yet',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Add your weight in the Home screen',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final currentWeight = logs.first.weight!;
    final previousWeight = logs.length > 1 ? logs[1].weight! : currentWeight;
    final weightChange = currentWeight - previousWeight;
    final bmi = stats.calculateBMI(currentWeight);
    final bodyFat = stats.calculateBodyFat(currentWeight);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildOverviewCard(
          context,
          title: 'Current Weight',
          value: '${currentWeight.toStringAsFixed(1)} kg',
          change: weightChange != 0
              ? '${weightChange > 0 ? '+' : ''}${weightChange.toStringAsFixed(1)} kg'
              : null,
          changeColor: weightChange > 0 ? AppTheme.errorColor : AppTheme.successColor,
          icon: Icons.monitor_weight,
        ),
        _buildOverviewCard(
          context,
          title: 'BMI',
          value: bmi?.toStringAsFixed(1) ?? 'N/A',
          subtitle: bmi != null ? _getBMICategory(bmi) : null,
          icon: Icons.accessibility,
        ),
        _buildOverviewCard(
          context,
          title: 'Body Fat %',
          value: bodyFat != null ? '${bodyFat.toStringAsFixed(1)}%' : 'N/A',
          icon: Icons.percent,
        ),
        _buildOverviewCard(
          context,
          title: 'Total Entries',
          value: '${logs.length}',
          subtitle: 'days tracked',
          icon: Icons.calendar_today,
        ),
      ],
    );
  }

  Widget _buildOverviewCard(
    BuildContext context, {
    required String title,
    required String value,
    String? change,
    Color? changeColor,
    String? subtitle,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (change != null)
                  Text(
                    change,
                    style: TextStyle(
                      color: changeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSelector() {
    final options = ['Weight', 'Calories', 'Workouts'];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.asMap().entries.map((entry) {
          final isSelected = _selectedChartIndex == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(entry.value),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedChartIndex = entry.key;
                  });
                }
              },
              selectedColor: AppTheme.primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChart(BuildContext context, List<DailyLog> logs, List<CompletedWorkout> workouts) {
    final reversedLogs = logs.reversed.toList();
    
    List<FlSpot> spots;
    String yAxisLabel;
    double maxY;
    double minY;
    
    switch (_selectedChartIndex) {
      case 0: // Weight
        spots = reversedLogs.asMap().entries.map((entry) {
          return FlSpot(entry.key.toDouble(), entry.value.weight ?? 0);
        }).toList();
        yAxisLabel = 'kg';
        final weights = logs.map((l) => l.weight ?? 0).toList();
        maxY = weights.reduce((a, b) => a > b ? a : b) + 2;
        minY = weights.reduce((a, b) => a < b ? a : b) - 2;
        break;
      case 1: // Calories
        spots = reversedLogs.asMap().entries.map((entry) {
          return FlSpot(entry.key.toDouble(), entry.value.calories.toDouble());
        }).toList();
        yAxisLabel = 'kcal';
        final calories = logs.map((l) => l.calories.toDouble()).toList();
        maxY = calories.reduce((a, b) => a > b ? a : b) + 200;
        minY = 0;
        break;
      case 2: // Workouts
        final workoutCounts = <String, int>{};
        for (final log in reversedLogs) {
          final count = workouts.where((w) => w.date == log.date).length;
          workoutCounts[log.date] = count;
        }
        spots = reversedLogs.asMap().entries.map((entry) {
          return FlSpot(entry.key.toDouble(), workoutCounts[entry.value.date]?.toDouble() ?? 0);
        }).toList();
        yAxisLabel = 'workouts';
        maxY = 5;
        minY = 0;
        break;
      default:
        spots = [];
        yAxisLabel = '';
        maxY = 100;
        minY = 0;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${['Weight Trend', 'Calorie Intake', 'Workout Frequency'][_selectedChartIndex]} - Last ${spots.length} Days',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (maxY - minY) / 4,
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(0),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minY: minY,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppTheme.primaryColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppTheme.primaryColor.withOpacity(0.1),
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

  Widget _buildInsufficientDataCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.show_chart, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'Need More Data',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Track your weight for at least 2 days to see the chart',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentLogs(BuildContext context, List<DailyLog> logs) {
    final recentLogs = logs.take(7).toList();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Entries',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () => _showWeightEntryDialog(context, ref),
                  child: const Text('Add Entry'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentLogs.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No entries yet',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentLogs.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final log = recentLogs[index];
                  final date = DateTime.parse(log.date);
                  final isToday = DateFormat('yyyy-MM-dd').format(DateTime.now()) == log.date;
                  
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: Icon(Icons.calendar_today, color: AppTheme.primaryColor, size: 18),
                    ),
                    title: Text(
                      isToday ? 'Today' : DateFormat('MMM d, yyyy').format(date),
                    ),
                    subtitle: Text(
                      'Calories: ${log.calories} kcal',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: log.weight != null
                        ? Text(
                            '${log.weight!.toStringAsFixed(1)} kg',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : Text(
                            'No weight',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  void _showEditStatsDialog(BuildContext context, WidgetRef ref, UserStats stats) {
    final heightController = TextEditingController(
      text: stats.height?.toString() ?? '',
    );
    final neckController = TextEditingController(
      text: stats.neck?.toString() ?? '',
    );
    final waistController = TextEditingController(
      text: stats.waist?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Body Measurements'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: heightController,
                decoration: const InputDecoration(
                  labelText: 'Height (cm)',
                  hintText: 'e.g., 175',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: neckController,
                decoration: const InputDecoration(
                  labelText: 'Neck Circumference (cm)',
                  hintText: 'e.g., 38',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: waistController,
                decoration: const InputDecoration(
                  labelText: 'Waist Circumference (cm)',
                  hintText: 'e.g., 85',
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

              if (height != null) {
                ref.read(userStatsNotifierProvider.notifier).updateHeight(height);
              }
              if (neck != null) {
                ref.read(userStatsNotifierProvider.notifier).updateNeck(neck);
              }
              if (waist != null) {
                ref.read(userStatsNotifierProvider.notifier).updateWaist(waist);
              }

              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showWeightEntryDialog(BuildContext context, WidgetRef ref) {
    final weightController = TextEditingController();
    final dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Weight Entry'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: weightController,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  hintText: 'e.g., 75.5',
                ),
                keyboardType: TextInputType.number,
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: 'Date (YYYY-MM-DD)',
                ),
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
              final weight = double.tryParse(weightController.text);
              if (weight != null) {
                ref.read(dailyLogNotifierProvider(dateController.text).notifier).updateWeight(weight);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
