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
  bool _showNeck = true;
  bool _showWaist = true;

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
              if (allLogs.length >= 2)
                _buildChart(context, allLogs, completedWorkouts)
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

  Widget _buildStatsOverview(
    BuildContext context,
    List<DailyLog> logs,
    UserStats stats,
  ) {
    if (logs.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.monitor_weight_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
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
          changeColor: weightChange > 0
              ? AppTheme.errorColor
              : AppTheme.successColor,
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
                Text(title, style: Theme.of(context).textTheme.bodyMedium),
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
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSelector() {
    final options = ['Weight', 'Calories', 'Workouts', 'Measurements', 'Sleep'];

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
              labelStyle: TextStyle(color: isSelected ? Colors.white : null),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChart(
    BuildContext context,
    List<DailyLog> logs,
    List<CompletedWorkout> workouts,
  ) {
    // Sort logs by date to ensure correct order
    final sortedLogs = List<DailyLog>.from(logs)
      ..sort((a, b) => a.date.compareTo(b.date));
    // Limit to last 14 days
    final displayLogs = sortedLogs.length > 14
        ? sortedLogs.sublist(sortedLogs.length - 14)
        : sortedLogs;

    List<LineChartBarData> lineBarsData = [];
    String yAxisLabel = '';
    double maxY = 100;
    double minY = 0;

    switch (_selectedChartIndex) {
      case 0: // Weight
        final spots = displayLogs
            .asMap()
            .entries
            .where((e) => e.value.weight != null)
            .map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.weight!);
            })
            .toList();
        yAxisLabel = 'kg';
        final weights = displayLogs
            .where((l) => l.weight != null)
            .map((l) => l.weight!)
            .toList();
        maxY = weights.isNotEmpty
            ? weights.reduce((a, b) => a > b ? a : b) + 2
            : 100;
        minY = weights.isNotEmpty
            ? weights.reduce((a, b) => a < b ? a : b) - 2
            : 0;
        lineBarsData.add(
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppTheme.primaryColor,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primaryColor.withOpacity(0.1),
            ),
          ),
        );
        break;
      case 1: // Calories
        final spots = displayLogs.asMap().entries.map((entry) {
          return FlSpot(entry.key.toDouble(), entry.value.calories.toDouble());
        }).toList();
        yAxisLabel = 'kcal';
        final calories = displayLogs.map((l) => l.calories.toDouble()).toList();
        maxY = calories.reduce((a, b) => a > b ? a : b) + 200;
        minY = 0;
        lineBarsData.add(
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.orange,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.orange.withOpacity(0.1),
            ),
          ),
        );
        break;
      case 2: // Workouts
        final spots = displayLogs.asMap().entries.map((entry) {
          final count = workouts
              .where((w) => w.date == entry.value.date)
              .length;
          return FlSpot(entry.key.toDouble(), count.toDouble());
        }).toList();
        yAxisLabel = 'count';
        maxY = 5;
        minY = 0;
        lineBarsData.add(
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: Colors.purple,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
        );
        break;
      case 3: // Measurements (Neck & Waist)
        if (_showNeck) {
          final neckSpots = displayLogs
              .asMap()
              .entries
              .where((e) => e.value.neck != null)
              .map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.neck!);
              })
              .toList();
          lineBarsData.add(
            LineChartBarData(
              spots: neckSpots,
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              dotData: const FlDotData(show: true),
            ),
          );
        }
        if (_showWaist) {
          final waistSpots = displayLogs
              .asMap()
              .entries
              .where((e) => e.value.waist != null)
              .map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.waist!);
              })
              .toList();
          lineBarsData.add(
            LineChartBarData(
              spots: waistSpots,
              isCurved: true,
              color: Colors.green,
              barWidth: 3,
              dotData: const FlDotData(show: true),
            ),
          );
        }
        yAxisLabel = 'cm';
        final allVals = displayLogs
            .expand(
              (l) => [
                if (_showNeck && l.neck != null) l.neck!,
                if (_showWaist && l.waist != null) l.waist!,
              ],
            )
            .toList();
        maxY = allVals.isNotEmpty
            ? allVals.reduce((a, b) => a > b ? a : b) + 5
            : 100;
        minY = allVals.isNotEmpty
            ? allVals.reduce((a, b) => a < b ? a : b) - 5
            : 0;
        break;
      case 4: // Sleep
        final spots = displayLogs.asMap().entries.map((entry) {
          return FlSpot(
            entry.key.toDouble(),
            (entry.value.sleepDuration ?? 0) / 60.0,
          );
        }).toList();
        yAxisLabel = 'hours';
        maxY = 12;
        minY = 0;
        lineBarsData.add(
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.indigo,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.indigo.withOpacity(0.1),
            ),
          ),
        );
        break;
    }

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
                  _getChartTitle(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_selectedChartIndex == 3)
                  Row(
                    children: [
                      _buildToggle(
                        'Neck',
                        Colors.blue,
                        _showNeck,
                        (v) => setState(() => _showNeck = v),
                      ),
                      const SizedBox(width: 8),
                      _buildToggle(
                        'Waist',
                        Colors.green,
                        _showWaist,
                        (v) => setState(() => _showWaist = v),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 280,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.1),
                      strokeWidth: 1,
                    ),
                    getDrawingVerticalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.1),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(
                          value.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < displayLogs.length) {
                            final date = DateTime.parse(
                              displayLogs[index].date,
                            );
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              angle: -0.8,
                              space: 12,
                              child: Text(
                                DateFormat('dd/MM/yy').format(date),
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
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
                  lineBarsData: lineBarsData,
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            '${spot.y.toStringAsFixed(1)} $yAxisLabel',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getChartTitle() {
    switch (_selectedChartIndex) {
      case 0:
        return 'Weight Trend';
      case 1:
        return 'Calorie Intake';
      case 2:
        return 'Workout Frequency';
      case 3:
        return 'Body Measurements';
      case 4:
        return 'Sleep Quality';
      default:
        return 'Trend';
    }
  }

  Widget _buildToggle(
    String label,
    Color color,
    bool value,
    Function(bool) onChanged,
  ) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: value ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: value ? color : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: value ? color : Colors.grey,
                fontWeight: FontWeight.bold,
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
              'Track your stats for at least 2 days to see the chart',
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
                  final isToday =
                      DateFormat('yyyy-MM-dd').format(DateTime.now()) ==
                      log.date;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: Icon(
                        Icons.calendar_today,
                        color: AppTheme.primaryColor,
                        size: 18,
                      ),
                    ),
                    title: Text(
                      isToday
                          ? 'Today'
                          : DateFormat('MMM d, yyyy').format(date),
                    ),
                    subtitle: Text(
                      'Calories: ${log.calories} kcal',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: log.weight != null
                        ? Text(
                            '${log.weight!.toStringAsFixed(1)} kg',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
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

  void _showEditStatsDialog(
    BuildContext context,
    WidgetRef ref,
    UserStats stats,
  ) {
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
              ref
                  .read(userStatsNotifierProvider.notifier)
                  .updateMeasurements(height: height, neck: neck, waist: waist);
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
                ref
                    .read(
                      dailyLogNotifierProvider(dateController.text).notifier,
                    )
                    .updateWeight(weight);
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
