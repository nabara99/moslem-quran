import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class EngagementProvider with ChangeNotifier {
  DateTime? _sessionStartTime;
  Timer? _saveTimer;
  int _weeklyMinutes = 0; // Total minutes this week

  int get weeklyMinutes => _weeklyMinutes;

  String get formattedWeeklyTime {
    final hours = _weeklyMinutes ~/ 60;
    final minutes = _weeklyMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  EngagementProvider() {
    _loadEngagementData();
  }

  /// Load saved engagement data
  Future<void> _loadEngagementData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get saved weekly minutes
      _weeklyMinutes = prefs.getInt('weekly_minutes') ?? 0;

      // Get last reset date
      final lastResetString = prefs.getString('last_weekly_reset');
      final lastReset = lastResetString != null
          ? DateTime.parse(lastResetString)
          : null;

      // Reset if it's a new week
      if (lastReset != null && _isNewWeek(lastReset)) {
        _weeklyMinutes = 0;
        await _saveWeeklyData();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading engagement data: $e');
    }
  }

  /// Check if current date is in a new week compared to last reset
  bool _isNewWeek(DateTime lastReset) {
    final now = DateTime.now();

    // Get the start of the week (Monday) for both dates
    final lastResetWeekStart = lastReset.subtract(Duration(days: lastReset.weekday - 1));
    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));

    // Compare only the date parts (ignore time)
    return DateTime(currentWeekStart.year, currentWeekStart.month, currentWeekStart.day)
        .isAfter(DateTime(lastResetWeekStart.year, lastResetWeekStart.month, lastResetWeekStart.day));
  }

  /// Save weekly data to SharedPreferences
  Future<void> _saveWeeklyData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('weekly_minutes', _weeklyMinutes);
      await prefs.setString('last_weekly_reset', DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Error saving weekly data: $e');
    }
  }

  /// Start tracking reading session
  void startSession() {
    if (_sessionStartTime == null) {
      _sessionStartTime = DateTime.now();

      // Auto-save every 30 seconds
      _saveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        _updateSessionTime();
      });
    }
  }

  /// Stop tracking reading session
  void stopSession() {
    if (_sessionStartTime != null) {
      _updateSessionTime();
      _sessionStartTime = null;
      _saveTimer?.cancel();
      _saveTimer = null;
    }
  }

  /// Update and save session time
  void _updateSessionTime() {
    if (_sessionStartTime != null) {
      final now = DateTime.now();
      final sessionDuration = now.difference(_sessionStartTime!);
      final sessionMinutes = sessionDuration.inMinutes;

      if (sessionMinutes > 0) {
        _weeklyMinutes += sessionMinutes;
        _sessionStartTime = now; // Reset start time for next interval
        _saveWeeklyData();
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    stopSession();
    super.dispose();
  }
}
