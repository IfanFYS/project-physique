import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:math' as math;
import '../providers/providers.dart';
import '../models/models.dart';
import '../utils/theme.dart';

class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key});

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  int _currentIndex = 0;
  bool _isTransformationMode = false;
  RangeValues _selectedRange = const RangeValues(0, 1);
  double _scrubValue = 0;
  final ImagePicker _picker = ImagePicker();
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allLogs = ref.watch(allDailyLogsProvider);
    final userStats = ref.watch(userStatsNotifierProvider);
    final logsWithPhotos = allLogs
        .where((log) => log.photoPath != null)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Gallery'),
        actions: [
          IconButton(
            icon: Icon(
              _isTransformationMode ? Icons.grid_view : Icons.auto_awesome,
            ),
            onPressed: () {
              setState(() {
                _isTransformationMode = !_isTransformationMode;
                _scrubValue = 0;
              });
            },
            tooltip: _isTransformationMode
                ? 'Grid View'
                : 'Transformation Mode',
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt),
            tooltip: 'Take Photo',
            onPressed: () => _takePhoto(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.photo_library),
            tooltip: 'Pick from Gallery',
            onPressed: () => _pickPhoto(context, ref),
          ),
        ],
      ),
      body: logsWithPhotos.isEmpty
          ? _buildEmptyState(context, ref)
          : _isTransformationMode
          ? _buildTransformationView(context, ref, logsWithPhotos, userStats)
          : _buildGallery(context, ref, logsWithPhotos, userStats),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.photo_camera_outlined,
                size: 56,
                color: AppTheme.primaryColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Progress Photos Yet',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Take regular photos to visually track your transformation over time.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _takePhoto(context, ref),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Photo'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _pickPhoto(context, ref),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Choose from Gallery'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransformationView(
    BuildContext context,
    WidgetRef ref,
    List<DailyLog> logs,
    UserStats userStats,
  ) {
    // Sort logs by date ascending for the timeline
    final sortedLogs = List<DailyLog>.from(logs)
      ..sort((a, b) => a.date.compareTo(b.date));

    if (sortedLogs.length < 2) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'Need at Least 2 Photos',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Add more progress photos to unlock Transformation Mode.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isTransformationMode = false;
                  });
                },
                icon: const Icon(Icons.grid_view),
                label: const Text('Back to Gallery'),
              ),
            ],
          ),
        ),
      );
    }

    // Clamp range to valid indices
    final maxIdx = (sortedLogs.length - 1).toDouble();
    if (_selectedRange.end > maxIdx) {
      _selectedRange = RangeValues(0, maxIdx);
    }

    final int startIdx = _selectedRange.start.round().clamp(
      0,
      sortedLogs.length - 1,
    );
    final int endIdx = _selectedRange.end.round().clamp(
      0,
      sortedLogs.length - 1,
    );
    final rangeSpan = (endIdx - startIdx).clamp(1, sortedLogs.length - 1);

    // Clamp scrub value to the selected range
    final clampedScrub = _scrubValue.clamp(
      startIdx.toDouble(),
      endIdx.toDouble(),
    );
    if (clampedScrub != _scrubValue) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _scrubValue = clampedScrub);
      });
    }

    final currentLog =
        sortedLogs[_scrubValue.round().clamp(0, sortedLogs.length - 1)];

    return Column(
      children: [
        Expanded(
          flex: 4,
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImage(currentLog.photoPath!),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: _buildPhotoStats(
                        context,
                        log: currentLog,
                        userStats: userStats,
                        dateStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        statStyle: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  // Progress badge
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${(_scrubValue.round() - startIdx + 1)} / ${rangeSpan + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Drag to Scrub Through Progress',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Slider(
                value: _scrubValue.clamp(
                  startIdx.toDouble(),
                  endIdx.toDouble(),
                ),
                min: startIdx.toDouble(),
                max: endIdx.toDouble(),
                divisions: rangeSpan > 0 ? rangeSpan : 1,
                onChanged: (value) {
                  setState(() {
                    _scrubValue = value;
                  });
                },
                activeColor: AppTheme.primaryColor,
              ),
              const Divider(),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.date_range, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Set Date Range:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              RangeSlider(
                values: _selectedRange,
                min: 0,
                max: maxIdx,
                divisions: sortedLogs.length > 1 ? sortedLogs.length - 1 : 1,
                labels: RangeLabels(
                  DateFormat(
                    'MMM d',
                  ).format(DateTime.parse(sortedLogs[startIdx].date)),
                  DateFormat(
                    'MMM d',
                  ).format(DateTime.parse(sortedLogs[endIdx].date)),
                ),
                onChanged: (values) {
                  setState(() {
                    _selectedRange = values;
                    _scrubValue = _scrubValue.clamp(values.start, values.end);
                  });
                },
                activeColor: AppTheme.accentColor,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat(
                      'MMM d, yyyy',
                    ).format(DateTime.parse(sortedLogs.first.date)),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    DateFormat(
                      'MMM d, yyyy',
                    ).format(DateTime.parse(sortedLogs.last.date)),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGallery(
    BuildContext context,
    WidgetRef ref,
    List<DailyLog> logsWithPhotos,
    UserStats userStats,
  ) {
    // Sort logs by date descending for the gallery view
    final sortedLogs = List<DailyLog>.from(logsWithPhotos)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Clamp _currentIndex just in case
    final safeIndex = _currentIndex.clamp(0, sortedLogs.length - 1);

    return Column(
      children: [
        Expanded(
          flex: 3,
          child: PageView.builder(
            controller: _pageController,
            itemCount: sortedLogs.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final log = sortedLogs[index];
              return _buildPhotoCard(
                context,
                log,
                index,
                sortedLogs.length,
                userStats,
              );
            },
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              children: [
                if (sortedLogs.length > 1) ...[
                  _buildPhotoThumbnailStrip(context, sortedLogs),
                  const SizedBox(height: 12),
                ],
                _buildPhotoInfo(context, sortedLogs[safeIndex], userStats),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _takePhoto(context, ref),
                      icon: const Icon(Icons.camera_alt, size: 18),
                      label: const Text('Take Photo'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () =>
                          _deletePhoto(context, ref, sortedLogs[safeIndex]),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppTheme.errorColor,
                        size: 18,
                      ),
                      label: const Text(
                        'Delete',
                        style: TextStyle(color: AppTheme.errorColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoCard(
    BuildContext context,
    DailyLog log,
    int index,
    int total,
    UserStats userStats,
  ) {
    final date = DateTime.parse(log.date);
    final isToday = DateFormat('yyyy-MM-dd').format(DateTime.now()) == log.date;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildImage(log.photoPath!),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.75),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: _buildPhotoStats(
                  context,
                  log: log,
                  userStats: userStats,
                  isToday: isToday,
                  date: date,
                  dateStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    shadows: const [
                      Shadow(blurRadius: 4, color: Colors.black54),
                    ],
                  ),
                  statStyle: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${index + 1} / $total',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoThumbnailStrip(BuildContext context, List<DailyLog> logs) {
    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: logs.length,
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemBuilder: (context, index) {
          final log = logs[index];
          final isSelected = index == _currentIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                _currentIndex = index;
              });
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: isSelected
                    ? Border.all(color: AppTheme.primaryColor, width: 2.5)
                    : Border.all(color: Colors.transparent, width: 2.5),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Opacity(
                  opacity: isSelected ? 1.0 : 0.65,
                  child: _buildImage(log.photoPath!),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhotoInfo(
    BuildContext context,
    DailyLog log,
    UserStats userStats,
  ) {
    final date = DateTime.parse(log.date);
    final isToday = DateFormat('yyyy-MM-dd').format(DateTime.now()) == log.date;

    // Compute BMI using log weight + userStats height
    final weight = log.weight;
    final bmi = weight != null ? userStats.calculateBMI(weight) : null;

    // BFP: use per-day neck/waist from log if available, else fall back to userStats
    double? bfp;
    if (weight != null) {
      final neck = log.neck ?? userStats.neck;
      final waist = log.waist ?? userStats.waist;
      final height = userStats.height;
      if (height != null && neck != null && waist != null && waist > neck) {
        final log10waistNeck = math.log(waist - neck) / math.log(10);
        final log10height = math.log(height) / math.log(10);
        bfp =
            (495 / (1.0324 - 0.19077 * log10waistNeck + 0.15456 * log10height) -
                    450)
                .clamp(0.0, 100.0);
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.12)),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 4,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 4),
              Text(
                isToday ? 'Today' : DateFormat('EEE, MMM d, yyyy').format(date),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          if (weight != null) ...[
            _infoPill(
              context,
              Icons.monitor_weight,
              '${weight.toStringAsFixed(1)} kg',
              AppTheme.successColor,
            ),
          ],
          if (bmi != null)
            _infoPill(
              context,
              Icons.accessibility,
              'BMI ${bmi.toStringAsFixed(1)}',
              Colors.orange,
            ),
          if (bfp != null)
            _infoPill(
              context,
              Icons.percent,
              'BFP ${bfp.toStringAsFixed(1)}%',
              Colors.blue,
            ),
        ],
      ),
    );
  }

  Widget _infoPill(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Shared overlay stats block for photo cards (on-image, bottom gradient)
  Widget _buildPhotoStats(
    BuildContext context, {
    required DailyLog log,
    required UserStats userStats,
    bool isToday = false,
    DateTime? date,
    required TextStyle dateStyle,
    required TextStyle statStyle,
  }) {
    final weight = log.weight;
    final bmi = weight != null ? userStats.calculateBMI(weight) : null;

    double? bfp;
    if (weight != null) {
      final neck = log.neck ?? userStats.neck;
      final waist = log.waist ?? userStats.waist;
      final height = userStats.height;
      if (height != null && neck != null && waist != null && waist > neck) {
        final log10waistNeck = math.log(waist - neck) / math.log(10);
        final log10height = math.log(height) / math.log(10);
        bfp =
            (495 / (1.0324 - 0.19077 * log10waistNeck + 0.15456 * log10height) -
                    450)
                .clamp(0.0, 100.0);
      }
    }

    final displayDate = isToday
        ? 'Today'
        : date != null
        ? DateFormat('MMMM d, yyyy').format(date)
        : log.date;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(displayDate, style: dateStyle),
        if (weight != null || bmi != null || bfp != null)
          const SizedBox(height: 4),
        Wrap(
          spacing: 10,
          runSpacing: 2,
          children: [
            if (weight != null)
              Text('${weight.toStringAsFixed(1)} kg', style: statStyle),
            if (bmi != null)
              Text('BMI ${bmi.toStringAsFixed(1)}', style: statStyle),
            if (bfp != null)
              Text('BFP ${bfp.toStringAsFixed(1)}%', style: statStyle),
          ],
        ),
      ],
    );
  }

  Future<void> _takePhoto(BuildContext context, WidgetRef ref) async {
    if (kIsWeb) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Camera not supported on web. Please use the gallery picker.',
            ),
          ),
        );
      }
      await _pickPhoto(context, ref);
      return;
    }
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (photo != null && context.mounted) {
        await _savePhoto(context, ref, photo);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error taking photo: $e')));
      }
    }
  }

  Future<void> _pickPhoto(BuildContext context, WidgetRef ref) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (photo != null && context.mounted) {
        await _savePhoto(context, ref, photo);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking photo: $e')));
      }
    }
  }

  Future<void> _savePhoto(
    BuildContext context,
    WidgetRef ref,
    XFile photo,
  ) async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      String savedPath;

      if (kIsWeb) {
        // On web, we can't persist files — store the XFile path (object URL) directly.
        // It won't survive a page refresh, but it works for the session.
        savedPath = photo.path;
      } else {
        final appDir = await getApplicationDocumentsDirectory();
        final photosDir = Directory('${appDir.path}/photos');

        if (!await photosDir.exists()) {
          await photosDir.create(recursive: true);
        }

        final fileName =
            'progress_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final destPath = path.join(photosDir.path, fileName);

        await File(photo.path).copy(destPath);
        savedPath = destPath;
      }

      await ref
          .read(dailyLogNotifierProvider(today).notifier)
          .setPhotoPath(savedPath);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📸 Progress photo saved!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() {
          _currentIndex = 0;
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving photo: $e')));
      }
    }
  }

  void _deletePhoto(BuildContext context, WidgetRef ref, DailyLog log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photo'),
        content: const Text(
          'Are you sure you want to delete this progress photo? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (log.photoPath != null) {
                // Try to delete the file on native platforms
                if (!kIsWeb) {
                  try {
                    final file = File(log.photoPath!);
                    if (await file.exists()) {
                      await file.delete();
                    }
                  } catch (_) {
                    // File might not exist, continue
                  }
                }

                await ref
                    .read(dailyLogNotifierProvider(log.date).notifier)
                    .setPhotoPath(null);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Photo deleted'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  setState(() {
                    _currentIndex = 0;
                  });
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Builds an image widget that works on both web and native.
  Widget _buildImage(String imagePath) {
    // Network images (http/https) work everywhere
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: Colors.grey.shade100,
            child: Center(
              child: CircularProgressIndicator(
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded /
                          progress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                color: AppTheme.primaryColor,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildImageError(),
      );
    }

    // On web, local paths may be object URLs or blob URLs
    if (kIsWeb) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildImageError(),
      );
    }

    // Native: use File
    return Image.file(
      File(imagePath),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildImageError(),
    );
  }

  Widget _buildImageError() {
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.broken_image_outlined,
              color: Colors.grey.shade400,
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              'Image not found',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
