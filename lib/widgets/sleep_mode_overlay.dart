import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../utils/theme.dart';

class SleepModeOverlay extends ConsumerWidget {
  final Widget child;

  const SleepModeOverlay({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sleepMode = ref.watch(sleepModeNotifierProvider);

    return Stack(
      children: [
        child,
        if (sleepMode.isActive)
          GestureDetector(
            onTap: () {
              // Show confirmation to exit sleep mode
              _showExitSleepModeDialog(context, ref);
            },
            child: Container(
              color: Colors.black.withOpacity(0.85),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.nightlight_round,
                      size: 80,
                      color: AppTheme.accentColor.withOpacity(0.8),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Sleep Mode Active',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tracking your sleep...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Consumer(
                      builder: (context, ref, child) {
                        final startTime = sleepMode.startTime;
                        if (startTime == null) return const SizedBox.shrink();
                        
                        return StreamBuilder(
                          stream: Stream.periodic(const Duration(seconds: 1)),
                          builder: (context, snapshot) {
                            final duration = DateTime.now().difference(startTime);
                            final hours = duration.inHours.toString().padLeft(2, '0');
                            final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
                            final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
                            
                            return Text(
                              '$hours:$minutes:$seconds',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w300,
                                color: AppTheme.accentColor.withOpacity(0.9),
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 48),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: AppTheme.accentColor.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        'Tap anywhere to wake up',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showExitSleepModeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          'Wake Up?',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        content: Text(
          'Are you waking up now? This will end sleep tracking and record your sleep duration.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Continue Sleeping',
              style: TextStyle(
                color: AppTheme.accentColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final duration = ref.read(sleepModeNotifierProvider.notifier).endSleep();
              Navigator.pop(context);
              
              if (duration != null) {
                final now = DateTime.now();
                final yesterday = now.subtract(const Duration(days: 1));
                final dateString = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
                
                ref.read(dailyLogNotifierProvider(dateString).notifier).setSleepDuration(duration);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Good morning! You slept for ${duration ~/ 60} hours and ${duration % 60} minutes.',
                    ),
                    backgroundColor: AppTheme.successColor,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.black,
            ),
            child: const Text('Wake Up'),
          ),
        ],
      ),
    );
  }
}
