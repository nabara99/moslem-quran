import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/prayer_time.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Set local timezone (Asia/Jakarta for Indonesia)
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel with custom sound on Android
    await _createNotificationChannel();

    _initialized = true;
    debugPrint('[Notification] Service initialized');
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('[Notification] Tapped: ${response.payload}');
    // You can navigate to specific screens here if needed
  }

  /// Request notification permissions (for both Android 13+ and iOS)
  Future<bool> requestPermissions() async {
    if (!_initialized) await initialize();

    // Request Android notification permission (Android 13+)
    final androidPermission = await Permission.notification.request();
    debugPrint('[Notification] Android notification permission: $androidPermission');

    // Request exact alarm permission (Android 12+)
    // This is CRITICAL for scheduled notifications to work in release builds
    final alarmStatus = await Permission.scheduleExactAlarm.status;
    debugPrint('[Notification] Exact alarm status before request: $alarmStatus');

    if (!alarmStatus.isGranted) {
      final alarmPermission = await Permission.scheduleExactAlarm.request();
      debugPrint('[Notification] Exact alarm permission after request: $alarmPermission');

      // If still not granted, user needs to enable manually in settings
      if (!alarmPermission.isGranted) {
        debugPrint('[Notification] WARNING: Exact alarm permission not granted!');
        debugPrint('[Notification] User must enable "Alarms & reminders" in app settings');
      }
    }

    // Also request ignoreBatteryOptimizations to prevent app from being killed
    final batteryStatus = await Permission.ignoreBatteryOptimizations.status;
    debugPrint('[Notification] Battery optimization status: $batteryStatus');

    if (!batteryStatus.isGranted) {
      final batteryPermission = await Permission.ignoreBatteryOptimizations.request();
      debugPrint('[Notification] Battery optimization permission: $batteryPermission');
    }

    // Request iOS permissions
    final iosResult = await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    // Recreate Android notification channel to ensure sound is applied
    await _createNotificationChannel();

    final allGranted = await checkAllPermissions();
    debugPrint('[Notification] All permissions granted: $allGranted');

    return androidPermission.isGranted || (iosResult ?? true);
  }

  /// Check if all required permissions are granted
  Future<bool> checkAllPermissions() async {
    final notification = await Permission.notification.isGranted;
    final exactAlarm = await Permission.scheduleExactAlarm.isGranted;
    final battery = await Permission.ignoreBatteryOptimizations.isGranted;

    debugPrint('[Notification] Permission check - notification: $notification, exactAlarm: $exactAlarm, battery: $battery');

    return notification && exactAlarm;
  }

  /// Get detailed permission status for UI display
  Future<Map<String, bool>> getPermissionStatus() async {
    return {
      'notification': await Permission.notification.isGranted,
      'exactAlarm': await Permission.scheduleExactAlarm.isGranted,
      'batteryOptimization': await Permission.ignoreBatteryOptimizations.isGranted,
    };
  }

  /// Open app settings for user to manually enable permissions
  Future<bool> openSettings() async {
    return await openAppSettings();
  }

  /// Create/recreate notification channel
  Future<void> _createNotificationChannel() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // Delete existing channels first to reset settings
      await androidPlugin.deleteNotificationChannel('prayer_times');
      await androidPlugin.deleteNotificationChannel('prayer_times_default');

      // Create channel with default sound (more reliable in release builds)
      // Custom sound can cause issues if resource is not found
      const channel = AndroidNotificationChannel(
        'prayer_times',
        'Prayer Times',
        description: 'Notifications for Islamic prayer times',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      await androidPlugin.createNotificationChannel(channel);
      debugPrint('[Notification] Channel created with default sound');
    }
  }

  /// Number of days to schedule notifications in advance
  static const int _daysToSchedule = 7;

  /// Schedule all prayer notifications based on settings
  /// Schedules notifications for multiple days ahead to ensure reliability
  Future<void> schedulePrayerNotifications({
    required PrayerTime prayerTime,
    required Map<String, bool> enabledPrayers,
    required bool reminderEnabled,
    required int reminderMinutes,
  }) async {
    if (!_initialized) await initialize();

    // Cancel all existing notifications first
    await cancelAllNotifications();

    final now = DateTime.now();
    final prayers = [
      {'name': 'Subuh', 'time': prayerTime.fajr, 'id': 1, 'key': 'fajr'},
      {'name': 'Dzuhur', 'time': prayerTime.dhuhr, 'id': 2, 'key': 'dhuhr'},
      {'name': 'Ashar', 'time': prayerTime.asr, 'id': 3, 'key': 'asr'},
      {'name': 'Maghrib', 'time': prayerTime.maghrib, 'id': 4, 'key': 'maghrib'},
      {'name': 'Isya', 'time': prayerTime.isha, 'id': 5, 'key': 'isha'},
    ];

    int scheduledCount = 0;

    // Schedule notifications for multiple days ahead
    for (int dayOffset = 0; dayOffset < _daysToSchedule; dayOffset++) {
      final targetDate = now.add(Duration(days: dayOffset));

      for (var prayer in prayers) {
        final prayerName = prayer['name'] as String;
        final prayerTimeStr = prayer['time'] as String;
        final baseNotificationId = prayer['id'] as int;
        final prayerKey = prayer['key'] as String;

        // Check if this prayer notification is enabled
        if (enabledPrayers[prayerKey] != true) continue;

        try {
          // Parse prayer time (format: "HH:mm")
          final timeParts = prayerTimeStr.split(':');
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);

          // Create DateTime for prayer time on target date
          final scheduledDate = DateTime(
            targetDate.year,
            targetDate.month,
            targetDate.day,
            hour,
            minute,
          );

          // Skip if the time has already passed
          if (scheduledDate.isBefore(now)) continue;

          // Generate unique notification ID: dayOffset * 100 + baseId
          // This allows up to 100 notifications per day
          final notificationId = dayOffset * 100 + baseNotificationId;

          // Schedule main prayer notification
          await _scheduleNotification(
            id: notificationId,
            title: 'Waktu $prayerName',
            body: 'Sudah masuk waktu sholat $prayerName',
            scheduledDate: scheduledDate,
          );
          scheduledCount++;

          // Schedule reminder if enabled
          if (reminderEnabled && reminderMinutes > 0) {
            final reminderDate = scheduledDate.subtract(
              Duration(minutes: reminderMinutes),
            );

            // Only schedule reminder if it's in the future
            if (reminderDate.isAfter(now)) {
              await _scheduleNotification(
                id: notificationId + 50, // Offset ID for reminders
                title: 'Pengingat Sholat $prayerName',
                body: '$reminderMinutes menit lagi waktu sholat $prayerName',
                scheduledDate: reminderDate,
              );
              scheduledCount++;
            }
          }
        } catch (e) {
          debugPrint('[Notification] Error scheduling $prayerName day $dayOffset: $e');
        }
      }
    }

    debugPrint('[Notification] Scheduled $scheduledCount notifications for $_daysToSchedule days');
  }

  /// Schedule a single notification
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'prayer_times',
      'Prayer Times',
      channelDescription: 'Notifications for Islamic prayer times',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      // Use alarmClock mode - more reliable for critical notifications
      // This uses AlarmManager.setAlarmClock() which bypasses battery optimization
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint('[Notification] Scheduled: $title at $scheduledDate');
  }

  /// Test scheduled notification (1 minute from now) - for debugging
  Future<void> testScheduledNotification() async {
    if (!_initialized) await initialize();

    final scheduledDate = DateTime.now().add(const Duration(minutes: 1));

    const androidDetails = AndroidNotificationDetails(
      'prayer_times',
      'Prayer Times',
      channelDescription: 'Notifications for Islamic prayer times',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      999, // Test notification ID
      'Test Notifikasi',
      'Ini adalah test notifikasi terjadwal. Jika Anda melihat ini, notifikasi berfungsi!',
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint('[Notification] Test notification scheduled for: $scheduledDate');
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('[Notification] All notifications cancelled');
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Show immediate notification (for testing)
  Future<void> showImmediateNotification({
    required String title,
    required String body,
  }) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'prayer_times',
      'Prayer Times',
      channelDescription: 'Notifications for Islamic prayer times',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }

  /// Get list of pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Show simple notification without custom sound (for debugging)
  Future<void> showSimpleNotification() async {
    if (!_initialized) await initialize();

    // Use default sound, no custom sound
    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Channel',
      channelDescription: 'Test notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true, // Use default sound
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      998,
      'Test Simple',
      'Notifikasi tanpa suara custom - ${DateTime.now()}',
      notificationDetails,
    );

    debugPrint('[Notification] Simple notification shown');
  }
}
