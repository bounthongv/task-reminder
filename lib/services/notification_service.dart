import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final fln.FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      fln.FlutterLocalNotificationsPlugin();

  static const String _soundKey = 'notification_sound';

  // Available sounds - keys must match filename (without extension) if possible,
  // or mapped correctly. For Android, these go in res/raw.
  // We will assume some defaults.
  static const Map<String, String> soundOptions = {
    'Default': 'default', // uses system default
    'Chime': 'chime',
    'Beep': 'beep',
    // Add more as you add files
  };

  Future<void> init() async {
    // tz.initializeTimeZones();

    // Android Initialization
    const fln.AndroidInitializationSettings initializationSettingsAndroid =
        fln.AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS Initialization
    final fln.DarwinInitializationSettings initializationSettingsDarwin =
        fln.DarwinInitializationSettings();

    // Linux Initialization
    const fln.LinuxInitializationSettings initializationSettingsLinux =
        fln.LinuxInitializationSettings(defaultActionName: 'Open notification');

    // Windows Initialization
    const fln.WindowsInitializationSettings initializationSettingsWindows =
        fln.WindowsInitializationSettings(
      appName: 'Task Reminder',
      appUserModelId: 'com.example.task_reminder_flutter',
      guid: 'f5db39fd-ad1d-409b-bd5d-37568d12936d',
    );

    final fln.InitializationSettings initializationSettings = fln.InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
      windows: initializationSettingsWindows,
    );

    if (!kIsWeb) {
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (fln.NotificationResponse details) async {
          // Handle notification tap
        },
      );
    }
  }

  /*
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final String sound = await getSelectedSound();
    
    // Android Details
    fln.AndroidNotificationDetails androidDetails;
    
    if (sound == 'default') {
      androidDetails = const fln.AndroidNotificationDetails(
        'default_channel',
        'Default Channel',
        channelDescription: 'Default notification sound',
        importance: fln.Importance.max,
        priority: fln.Priority.high,
      );
    } else {
      androidDetails = fln.AndroidNotificationDetails(
        'channel_$sound',
        'Channel $sound', // Visible to user in settings
        channelDescription: 'Notifications with $sound sound',
        importance: fln.Importance.max,
        priority: fln.Priority.high,
        sound: fln.RawResourceAndroidNotificationSound(sound),
      );
    }

    // iOS Details
    final fln.DarwinNotificationDetails iosDetails = fln.DarwinNotificationDetails(
      sound: sound == 'default' ? null : '$sound.mp3', // iOS needs extension usually
    );

    final fln.NotificationDetails notificationDetails = fln.NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          fln.UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: fln.DateTimeComponents.dateAndTime,
    );
  }
  */

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // Settings Management
  Future<String> getSelectedSound() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_soundKey) ?? 'default';
  }

  Future<void> setSelectedSound(String soundKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_soundKey, soundKey);
  }
}
