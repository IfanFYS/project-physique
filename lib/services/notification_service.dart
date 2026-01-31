import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static const String sleepModeChannelId = 'sleep_mode_channel';
  static const String sleepModeNotificationTitle = 'Sleep Mode Active';
  static const String sleepModeNotificationBody = 'Tap to Wake Up';
  static const int sleepModeNotificationId = 1;

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
  }

  void _onNotificationResponse(NotificationResponse response) {
    // Handle notification tap
    if (response.id == sleepModeNotificationId) {
      // The app will handle this when it resumes
    }
  }

  Future<void> showSleepModeNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      sleepModeChannelId,
      'Sleep Mode',
      channelDescription: 'Persistent notification for sleep tracking',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      visibility: NotificationVisibility.public,
      playSound: false,
      enableVibration: false,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      sleepModeNotificationId,
      sleepModeNotificationTitle,
      sleepModeNotificationBody,
      details,
    );
  }

  Future<void> cancelSleepModeNotification() async {
    await _notifications.cancel(sleepModeNotificationId);
  }
}
