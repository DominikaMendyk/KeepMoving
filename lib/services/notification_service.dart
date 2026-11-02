import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/reminder.dart';

/// Shows a system notification (Windows toast and Android notification) when a reminder fires, so the
/// user notices it even while working in another window.
class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;
  int _nextId = 0;

  bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
       defaultTargetPlatform == TargetPlatform.android ||
       defaultTargetPlatform == TargetPlatform.iOS ||
       defaultTargetPlatform == TargetPlatform.macOS);

  Future<void> init() async {
    if (!_supported) return;
    try {
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinInit = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const windowsInit = WindowsInitializationSettings(
        appName: 'KeepMoving',
        appUserModelId: 'KeepMoving.Desktop.App',
        guid: 'c1f7a3e2-5b84-4d0a-9e61-7a2f0d3b8c15',
      );

      await _plugin.initialize(
        settings: const InitializationSettings(
          android: androidInit,
          iOS: darwinInit,
          macOS: darwinInit,
          windows: windowsInit,
        ),
      );

      // Request runtime permissions on Android 13+
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        await androidPlugin?.requestNotificationsPermission();
      }

      // Request permissions on iOS and macOS
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
        await iosPlugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      } else if (defaultTargetPlatform == TargetPlatform.macOS) {
        final macosPlugin = _plugin.resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>();
        await macosPlugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      _ready = true;
    } catch (e, s) {
      // A broken notification setup must never stop the app from starting.
      debugPrint('Notification init failed: $e\n$s');
    }
  }

  Future<void> showReminder(Reminder reminder) async {
    if (!_ready) return;

    final String title;
    final String body;
    switch (reminder.type) {
      case ReminderType.water:
        title = 'Time for a glass of water';
        body = 'Take a sip, then confirm it in KeepMoving.';
      case ReminderType.stretch:
        final s = reminder.stretch!;
        title = 'Stretch: ${s.name}';
        body = '${s.instruction} (about ${s.seconds} s)';
    }

    try {
      await _plugin.show(
        id: _nextId++,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'keep_moving_channel',
            'KeepMoving Reminders',
            channelDescription: 'Reminders to drink water and stretch during focus sessions',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
          macOS: DarwinNotificationDetails(),
          windows: WindowsNotificationDetails(),
        ),
      );
    } catch (e, s) {
      debugPrint('Showing notification failed: $e\n$s');
    }
  }
}
