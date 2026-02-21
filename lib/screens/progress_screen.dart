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

  // Timeframe: how many days to show (null = all)
  int? _timeframeDays = 14;

  // Target line per chart index
  final List<double?> _targetValues = [null, null, null, null, null];
  final List<bool> _showTarget = [false, false, false, false, false];
  final List<TextEditingController> _targetControllers = List.generate(
    5,
    (_) => TextEditingController(),
  );

  @override
  void dispose() {
    for (final c in _targetControllers) {
      c.dispose();
    }
    super.dispose();
  }

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
              showCheckmark: false,
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
                fontWeight: isSelected ? FontWeight.bold : null,
              ),
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
    final ci = _selectedChartIndex;

    // Sort by date ascending
    final sortedLogs = List<DailyLog>.from(logs)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Apply timeframe
    final displayLogs =
        (_timeframeDays != null && sortedLogs.length > _timeframeDays!)
        ? sortedLogs.sublist(sortedLogs.length - _timeframeDays!)
        : sortedLogs;

    List<LineChartBarData> lineBarsData = [];
    String yAxisLabel = '';
    double maxY = 100;
    double minY = 0;

    switch (ci) {
      case 0: // Weight
        final spots = displayLogs
            .asMap()
            .entries
            .where((e) => e.value.weight != null)
            .map((entry) => FlSpot(entry.key.toDouble(), entry.value.weight!))
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
        final spots = displayLogs
            .asMap()
            .entries
            .map((e) => FlSpot(e.key.toDouble(), e.value.calories.toDouble()))
            .toList();
        yAxisLabel = 'kcal';
        final calories = displayLogs.map((l) => l.calories.toDouble()).toList();
        maxY = calories.isNotEmpty
            ? calories.reduce((a, b) => a > b ? a : b) + 200
            : 500;
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
        yAxisLabel = 'sessions';
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
      case 3: // Measurements
        if (_showNeck) {
          final neckSpots = displayLogs
              .asMap()
              .entries
              .where((e) => e.value.neck != null)
              .map((e) => FlSpot(e.key.toDouble(), e.value.neck!))
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
              .map((e) => FlSpot(e.key.toDouble(), e.value.waist!))
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
        final spots = displayLogs
            .asMap()
            .entries
            .map(
              (e) =>
                  FlSpot(e.key.toDouble(), (e.value.sleepDuration ?? 0) / 60.0),
            )
            .toList();
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

    // Target line
    final targetVal = _targetValues[ci];
    final showTargetLine =
        _showTarget[ci] &&
        targetVal != null &&
        targetVal >= minY &&
        targetVal <= maxY;

    final extraLines = showTargetLine
        ? ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: targetVal,
                color: Colors.red.withOpacity(0.7),
                strokeWidth: 1.5,
                dashArray: [6, 4],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.only(right: 8, bottom: 4),
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  labelResolver: (line) =>
                      'Target: ${line.y.toStringAsFixed(1)} $yAxisLabel',
                ),
              ),
            ],
          )
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title row + Timeframe Selector ──────────────────────────
            Row(
              children: [
                Expanded(
                  child: Text(
                    _getChartTitle(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                // Compact Timeframe Selector
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...[
                        ['7d', 7],
                        ['14d', 14],
                        ['30d', 30],
                        ['All', null],
                      ].map((opt) {
                        final label = opt[0] as String;
                        final days = opt[1] as int?;
                        final isSelected = _timeframeDays == days;
                        return GestureDetector(
                          onTap: () => setState(() => _timeframeDays = days),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppTheme.primaryColor
                                            .withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Neck/Waist toggles (if measurements) ─────────────────────
            if (ci == 3) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildToggle(
                    'Neck',
                    Colors.blue,
                    _showNeck,
                    (v) => setState(() => _showNeck = v),
                  ),
                  const SizedBox(width: 12),
                  _buildToggle(
                    'Waist',
                    Colors.green,
                    _showWaist,
                    (v) => setState(() => _showWaist = v),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 8),

            // ── Target line toggle + input ────────────────────────────────
            Row(
              children: [
                GestureDetector(
                  onTap: () =>
                      setState(() => _showTarget[ci] = !_showTarget[ci]),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 32,
                        height: 18,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9),
                          color: _showTarget[ci]
                              ? Colors.red.shade400
                              : Colors.grey.shade300,
                        ),
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 200),
                          alignment: _showTarget[ci]
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Target line',
                        style: TextStyle(
                          fontSize: 12,
                          color: _showTarget[ci]
                              ? Colors.red.shade400
                              : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_showTarget[ci]) ...[
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 80,
                    height: 30,
                    child: TextField(
                      controller: _targetControllers[ci],
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(fontSize: 12),
                      decoration: InputDecoration(
                        hintText: yAxisLabel,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        isDense: true,
                      ),
                      onChanged: (v) {
                        setState(() {
                          _targetValues[ci] = double.tryParse(v);
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    yAxisLabel,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // ── Chart ────────────────────────────────────────────────────
            SizedBox(
              height: 260,
              child: InteractiveViewer(
                clipBehavior: Clip.none,
                minScale: 1.0,
                maxScale: 4.0,
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: 20,
                    left: 4,
                    top: 10,
                    bottom: 4,
                  ),
                  child: LineChart(
                    LineChartData(
                      extraLinesData: extraLines,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        horizontalInterval: 1,
                        verticalInterval: 1,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.withOpacity(0.1),
                            strokeWidth: 1,
                          );
                        },
                        getDrawingVerticalLine: (value) {
                          return FlLine(
                            color: Colors.grey.withOpacity(0.1),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            interval: (displayLogs.length / 5)
                                .clamp(1, 100)
                                .toDouble(),
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < displayLogs.length) {
                                final date = DateTime.parse(
                                  displayLogs[index].date,
                                );
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  space: 8,
                                  child: Text(
                                    DateFormat('dd/MM').format(date),
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toStringAsFixed(0),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              );
                            },
                            reservedSize: 28,
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
                        enabled: true,
                        handleBuiltInTouches: true,
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
