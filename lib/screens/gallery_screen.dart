import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
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

  @override
  Widget build(BuildContext context) {
    final allLogs = ref.watch(allDailyLogsProvider);
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
              });
            },
            tooltip: 'Transformation Mode',
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () => _takePhoto(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: () => _pickPhoto(context, ref),
          ),
        ],
      ),
      body: logsWithPhotos.isEmpty
          ? _buildEmptyState(context, ref)
          : _isTransformationMode
          ? _buildTransformationView(context, ref, logsWithPhotos)
          : _buildGallery(context, ref, logsWithPhotos),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_camera_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No Progress Photos Yet',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Take photos to track your transformation',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                onPressed: () => _takePhoto(context, ref),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
              ),
              OutlinedButton.icon(
                onPressed: () => _pickPhoto(context, ref),
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
              ),
              TextButton.icon(
                onPressed: () => _addSampleData(ref),
                icon: const Icon(Icons.add_to_photos),
                label: const Text('Add Demo Data'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransformationView(
    BuildContext context,
    WidgetRef ref,
    List<DailyLog> logs,
  ) {
    // Sort logs by date ascending for the timeline
    final sortedLogs = List<DailyLog>.from(logs)
      ..sort((a, b) => a.date.compareTo(b.date));

    if (sortedLogs.length < 2) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Add at least 2 photos to use Transformation Mode'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isTransformationMode = false;
                });
              },
              child: const Text('Back to Gallery'),
            ),
          ],
        ),
      );
    }

    // Initialize range if needed
    if (_selectedRange.end >= sortedLogs.length) {
      _selectedRange = RangeValues(0, (sortedLogs.length - 1).toDouble());
    }

    final int startIdx = _selectedRange.start.round();
    final int endIdx = _selectedRange.end.round();

    // Clamp scrub value to the selected range
    if (_scrubValue < startIdx) _scrubValue = startIdx.toDouble();
    if (_scrubValue > endIdx) _scrubValue = endIdx.toDouble();

    final currentLog = sortedLogs[_scrubValue.round()];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Transformation Progress',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        Expanded(
          flex: 4,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat(
                              'MMMM d, yyyy',
                            ).format(DateTime.parse(currentLog.date)),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (currentLog.weight != null)
                            Text(
                              'Weight: ${currentLog.weight!.toStringAsFixed(1)} kg',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              Text(
                'Scrub to see progress',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Slider(
                value: _scrubValue,
                min: startIdx.toDouble(),
                max: endIdx.toDouble(),
                divisions: (endIdx - startIdx) > 0 ? (endIdx - startIdx) : 1,
                onChanged: (value) {
                  setState(() {
                    _scrubValue = value;
                  });
                },
                activeColor: AppTheme.primaryColor,
              ),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.date_range, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  const Text(
                    'Set View Range:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              RangeSlider(
                values: _selectedRange,
                min: 0,
                max: (sortedLogs.length - 1).toDouble(),
                divisions: sortedLogs.length - 1,
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
                    if (_scrubValue < values.start) _scrubValue = values.start;
                    if (_scrubValue > values.end) _scrubValue = values.end;
                  });
                },
                activeColor: AppTheme.secondaryColor,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat(
                      'MMM d, yyyy',
                    ).format(DateTime.parse(sortedLogs[0].date)),
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
  ) {
    // Sort logs by date descending for the gallery view
    final sortedLogs = List<DailyLog>.from(logsWithPhotos)
      ..sort((a, b) => b.date.compareTo(a.date));

    return Column(
      children: [
        Expanded(
          flex: 3,
          child: PageView.builder(
            itemCount: sortedLogs.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final log = sortedLogs[index];
              return _buildPhotoCard(context, log, index, sortedLogs.length);
            },
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (sortedLogs.length > 1)
                  _buildPhotoSlider(context, sortedLogs),
                const SizedBox(height: 16),
                _buildPhotoInfo(
                  context,
                  sortedLogs[_currentIndex.clamp(0, sortedLogs.length - 1)],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _takePhoto(context, ref),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Take Photo'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => _deletePhoto(
                        context,
                        ref,
                        sortedLogs[_currentIndex.clamp(
                          0,
                          sortedLogs.length - 1,
                        )],
                      ),
                      icon: const Icon(
                        Icons.delete,
                        color: AppTheme.errorColor,
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
  ) {
    final date = DateTime.parse(log.date);
    final isToday = DateFormat('yyyy-MM-dd').format(DateTime.now()) == log.date;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
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
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isToday
                          ? 'Today'
                          : DateFormat('MMMM d, yyyy').format(date),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (log.weight != null)
                      Text(
                        'Weight: ${log.weight!.toStringAsFixed(1)} kg',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
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
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSlider(BuildContext context, List<DailyLog> logs) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(8),
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          final isSelected = index == _currentIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                _currentIndex = index;
              });
            },
            child: Container(
              width: 64,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? Border.all(color: AppTheme.primaryColor, width: 3)
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildImage(log.photoPath!),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhotoInfo(BuildContext context, DailyLog log) {
    final date = DateTime.parse(log.date);
    final isToday = DateFormat('yyyy-MM-dd').format(DateTime.now()) == log.date;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  isToday
                      ? 'Today'
                      : DateFormat('EEEE, MMMM d, yyyy').format(date),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (log.weight != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.monitor_weight,
                    size: 18,
                    color: AppTheme.successColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Weight: ${log.weight!.toStringAsFixed(1)} kg',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _takePhoto(BuildContext context, WidgetRef ref) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        await _savePhoto(context, ref, photo.path);
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
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        await _savePhoto(context, ref, photo.path);
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
    String sourcePath,
  ) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${appDir.path}/photos');

      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
      }

      final fileName = 'progress_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final destPath = path.join(photosDir.path, fileName);

      await File(sourcePath).copy(destPath);

      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await ref
          .read(dailyLogNotifierProvider(today).notifier)
          .setPhotoPath(destPath);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo saved successfully!')),
        );

        // Refresh to show the new photo
        setState(() {});
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
          'Are you sure you want to delete this progress photo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (log.photoPath != null) {
                try {
                  final file = File(log.photoPath!);
                  if (await file.exists()) {
                    await file.delete();
                  }
                } catch (e) {
                  // File might not exist, continue
                }

                await ref
                    .read(dailyLogNotifierProvider(log.date).notifier)
                    .setPhotoPath(null);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Photo deleted')),
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

  Widget _buildImage(String imagePath) {
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey.shade200,
          child: const Icon(Icons.error_outline, color: Colors.grey),
        ),
      );
    }
    return Image.file(File(imagePath), fit: BoxFit.cover);
  }

  void _addSampleData(WidgetRef ref) async {
    final now = DateTime.now();
    final samples = [
      {
        'date': DateFormat(
          'yyyy-MM-dd',
        ).format(now.subtract(const Duration(days: 60))),
        'weight': 88.0,
        'photo':
            'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?q=80&w=1000&auto=format&fit=crop',
      },
      {
        'date': DateFormat(
          'yyyy-MM-dd',
        ).format(now.subtract(const Duration(days: 45))),
        'weight': 85.5,
        'photo':
            'https://images.unsplash.com/photo-1594882645126-14020914d58d?q=80&w=1000&auto=format&fit=crop',
      },
      {
        'date': DateFormat(
          'yyyy-MM-dd',
        ).format(now.subtract(const Duration(days: 30))),
        'weight': 83.2,
        'photo':
            'https://images.unsplash.com/photo-1583454110551-21f2fa2ec617?q=80&w=1000&auto=format&fit=crop',
      },
      {
        'date': DateFormat(
          'yyyy-MM-dd',
        ).format(now.subtract(const Duration(days: 15))),
        'weight': 81.0,
        'photo':
            'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=1000&auto=format&fit=crop',
      },
      {
        'date': DateFormat('yyyy-MM-dd').format(now),
        'weight': 78.5,
        'photo':
            'https://images.unsplash.com/photo-1599058917232-d750c1859d7c?q=80&w=1000&auto=format&fit=crop',
      },
    ];

    for (var sample in samples) {
      final date = sample['date'] as String;
      final weight = sample['weight'] as double;
      final photo = sample['photo'] as String;

      final logNotifier = ref.read(dailyLogNotifierProvider(date).notifier);
      await logNotifier.updateWeight(weight);
      await logNotifier.setPhotoPath(photo);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Demo photos loaded successfully!')),
      );
      setState(() {});
    }
  }
}
