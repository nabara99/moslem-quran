import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../models/prayer_time.dart';

class NotificationSettingsProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  bool _fajrEnabled = true;
  bool _dhuhrEnabled = true;
  bool _asrEnabled = true;
  bool _maghribEnabled = true;
  bool _ishaEnabled = true;
  bool _reminderEnabled = false;
  int _reminderMinutes = 15;
  bool _isInitialized = false;

  PrayerTime? _prayerTime;

  bool get fajrEnabled => _fajrEnabled;
  bool get dhuhrEnabled => _dhuhrEnabled;
  bool get asrEnabled => _asrEnabled;
  bool get maghribEnabled => _maghribEnabled;
  bool get ishaEnabled => _ishaEnabled;
  bool get reminderEnabled => _reminderEnabled;
  int get reminderMinutes => _reminderMinutes;
  bool get isInitialized => _isInitialized;

  NotificationSettingsProvider() {
    _initializeAsync();
  }

  /// Properly sequenced async initialization
  Future<void> _initializeAsync() async {
    // Step 1: Load settings first (wait for completion)
    await _loadSettings();

    // Step 2: Initialize notification service
    await _notificationService.initialize();
    await _notificationService.requestPermissions();

    // Step 3: Load cached prayer times and schedule notifications
    await _loadCachedPrayerTimes();

    _isInitialized = true;
    notifyListeners();
    debugPrint('[NotificationSettings] Initialization complete');
  }

  /// Load prayer times from cache and schedule notifications
  Future<void> _loadCachedPrayerTimes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedDate = prefs.getString('prayer_cached_date');
      final today = DateTime.now().toIso8601String().split('T')[0];

      // Only use cache if it's from today
      if (cachedDate == today) {
        final prayerJson = prefs.getString('prayer_times');
        if (prayerJson != null) {
          _prayerTime = PrayerTime.fromJsonString(prayerJson);
          debugPrint('[Notification] Loaded prayer times from cache');

          // Check if we need to reschedule (daily check)
          if (await _shouldRescheduleNotifications(prefs)) {
            await _rescheduleNotifications();
            await _saveLastScheduleDate(prefs);
          }
        }
      }
    } catch (e) {
      debugPrint('[Notification] Error loading cached prayer times: $e');
    }
  }

  /// Check if notifications should be rescheduled
  Future<bool> _shouldRescheduleNotifications(SharedPreferences prefs) async {
    final lastScheduleDate = prefs.getString('notification_last_schedule_date');
    final today = DateTime.now().toIso8601String().split('T')[0];

    // Reschedule if never scheduled or if it's a new day
    if (lastScheduleDate == null || lastScheduleDate != today) {
      debugPrint('[Notification] Needs reschedule: last=$lastScheduleDate, today=$today');
      return true;
    }
    return false;
  }

  /// Save the last schedule date
  Future<void> _saveLastScheduleDate(SharedPreferences prefs) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setString('notification_last_schedule_date', today);
    debugPrint('[Notification] Saved last schedule date: $today');
  }

  /// Update prayer times and reschedule notifications
  Future<void> updatePrayerTimes(PrayerTime? prayerTime) async {
    _prayerTime = prayerTime;
    await _rescheduleNotifications();

    // Save the schedule date
    final prefs = await SharedPreferences.getInstance();
    await _saveLastScheduleDate(prefs);
  }

  /// Reschedule all notifications based on current settings
  Future<void> _rescheduleNotifications() async {
    if (_prayerTime == null) {
      debugPrint('[Notification] Cannot reschedule: no prayer time data');
      return;
    }

    debugPrint('[Notification] Rescheduling notifications...');
    await _notificationService.schedulePrayerNotifications(
      prayerTime: _prayerTime!,
      enabledPrayers: {
        'fajr': _fajrEnabled,
        'dhuhr': _dhuhrEnabled,
        'asr': _asrEnabled,
        'maghrib': _maghribEnabled,
        'isha': _ishaEnabled,
      },
      reminderEnabled: _reminderEnabled,
      reminderMinutes: _reminderMinutes,
    );
  }

  /// Force reschedule notifications (called externally when needed)
  Future<void> forceRescheduleNotifications() async {
    if (_prayerTime == null) return;

    await _rescheduleNotifications();
    final prefs = await SharedPreferences.getInstance();
    await _saveLastScheduleDate(prefs);
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _fajrEnabled = prefs.getBool('notification_fajr') ?? true;
      _dhuhrEnabled = prefs.getBool('notification_dhuhr') ?? true;
      _asrEnabled = prefs.getBool('notification_asr') ?? true;
      _maghribEnabled = prefs.getBool('notification_maghrib') ?? true;
      _ishaEnabled = prefs.getBool('notification_isha') ?? true;
      _reminderEnabled = prefs.getBool('notification_reminder') ?? false;
      _reminderMinutes = prefs.getInt('reminder_minutes') ?? 15;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading notification settings: $e');
    }
  }

  Future<void> toggleFajr(bool value) async {
    _fajrEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_fajr', value);
    await _rescheduleNotifications();
  }

  Future<void> toggleDhuhr(bool value) async {
    _dhuhrEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_dhuhr', value);
    await _rescheduleNotifications();
  }

  Future<void> toggleAsr(bool value) async {
    _asrEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_asr', value);
    await _rescheduleNotifications();
  }

  Future<void> toggleMaghrib(bool value) async {
    _maghribEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_maghrib', value);
    await _rescheduleNotifications();
  }

  Future<void> toggleIsha(bool value) async {
    _ishaEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_isha', value);
    await _rescheduleNotifications();
  }

  Future<void> toggleReminder(bool value) async {
    _reminderEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_reminder', value);
    await _rescheduleNotifications();
  }

  Future<void> setReminderMinutes(int minutes) async {
    _reminderMinutes = minutes;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminder_minutes', minutes);
    await _rescheduleNotifications();
  }
}
