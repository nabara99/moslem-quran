import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_time.dart';
import '../services/prayer_service.dart';
import '../services/notification_service.dart';

class PrayerProvider with ChangeNotifier {
  final PrayerService _prayerService = PrayerService();

  PrayerTime? _prayerTime;
  bool _isLoading = false;
  String? _error;
  String _locationName = 'Lokasi tidak diketahui';
  double? _latitude;
  double? _longitude;
  String? _cachedDate;

  PrayerTime? get prayerTime => _prayerTime;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get locationName => _locationName;
  double? get latitude => _latitude;
  double? get longitude => _longitude;

  /// Load cached data from SharedPreferences
  Future<bool> loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _cachedDate = prefs.getString('prayer_cached_date');
      final today = DateTime.now().toIso8601String().split('T')[0];

      // Check if cache is from today
      if (_cachedDate != today) {
        debugPrint('[Prayer] Cache expired or not found');
        return false;
      }

      final prayerJson = prefs.getString('prayer_times');
      _latitude = prefs.getDouble('prayer_latitude');
      _longitude = prefs.getDouble('prayer_longitude');
      _locationName = prefs.getString('prayer_location_name') ?? 'Lokasi tidak diketahui';

      if (prayerJson != null && _latitude != null && _longitude != null) {
        _prayerTime = PrayerTime.fromJsonString(prayerJson);
        debugPrint('[Prayer] Loaded from cache: $_locationName');
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('[Prayer] Error loading cache: $e');
      return false;
    }
  }

  /// Save current data to SharedPreferences
  Future<void> _saveToCache() async {
    if (_prayerTime == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];

      await prefs.setString('prayer_cached_date', today);
      await prefs.setString('prayer_times', _prayerTime!.toJsonString());
      if (_latitude != null) await prefs.setDouble('prayer_latitude', _latitude!);
      if (_longitude != null) await prefs.setDouble('prayer_longitude', _longitude!);
      await prefs.setString('prayer_location_name', _locationName);

      debugPrint('[Prayer] Saved to cache');

      // Schedule notifications after saving prayer times
      await _scheduleNotifications(prefs);
    } catch (e) {
      debugPrint('[Prayer] Error saving cache: $e');
    }
  }

  /// Schedule prayer notifications based on current settings
  Future<void> _scheduleNotifications(SharedPreferences prefs) async {
    try {
      // Load notification settings
      final fajrEnabled = prefs.getBool('notification_fajr') ?? true;
      final dhuhrEnabled = prefs.getBool('notification_dhuhr') ?? true;
      final asrEnabled = prefs.getBool('notification_asr') ?? true;
      final maghribEnabled = prefs.getBool('notification_maghrib') ?? true;
      final ishaEnabled = prefs.getBool('notification_isha') ?? true;
      final reminderEnabled = prefs.getBool('notification_reminder') ?? false;
      final reminderMinutes = prefs.getInt('reminder_minutes') ?? 15;

      // Schedule notifications using the notification service
      final notificationService = NotificationService();
      await notificationService.schedulePrayerNotifications(
        prayerTime: _prayerTime!,
        enabledPrayers: {
          'fajr': fajrEnabled,
          'dhuhr': dhuhrEnabled,
          'asr': asrEnabled,
          'maghrib': maghribEnabled,
          'isha': ishaEnabled,
        },
        reminderEnabled: reminderEnabled,
        reminderMinutes: reminderMinutes,
      );

      // Save the last schedule date to prevent duplicate scheduling
      final today = DateTime.now().toIso8601String().split('T')[0];
      await prefs.setString('notification_last_schedule_date', today);

      debugPrint('[Prayer] Notifications scheduled successfully for 7 days');
    } catch (e) {
      debugPrint('[Prayer] Error scheduling notifications: $e');
    }
  }

  Future<void> loadPrayerTimesByLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Layanan lokasi tidak aktif');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Izin lokasi ditolak');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi ditolak secara permanen');
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      );

      _latitude = position.latitude;
      _longitude = position.longitude;

      _prayerTime = await _prayerService.getPrayerTimesByCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      _locationName = await _getLocationName(position.latitude, position.longitude);
      await _saveToCache();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadPrayerTimesByCity(String city, String country) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _prayerTime = await _prayerService.getPrayerTimesByCity(
        city: city,
        country: country,
      );
      _locationName = '$city, $country';
      _latitude = null;
      _longitude = null;
      await _saveToCache();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Auto-detect location: tries cache first, then GPS, fallback to Jakarta
  Future<void> autoDetectLocation({bool forceRefresh = false}) async {
    // Try to load from cache first (unless force refresh)
    if (!forceRefresh) {
      final hasCache = await loadFromCache();
      if (hasCache) {
        debugPrint('[Prayer] Using cached data');
        return;
      }
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await _fallbackToJakarta();
        return;
      }

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          await _fallbackToJakarta();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        await _fallbackToJakarta();
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 15),
        ),
      );

      _latitude = position.latitude;
      _longitude = position.longitude;

      // Get prayer times
      _prayerTime = await _prayerService.getPrayerTimesByCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      // Get location name
      _locationName = await _getLocationName(position.latitude, position.longitude);

      // Save to cache
      await _saveToCache();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      await _fallbackToJakarta();
    }
  }

  /// Reverse geocoding: convert coordinates to readable location name
  Future<String> _getLocationName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        String subLocality = place.subLocality ?? '';
        String locality = place.locality ?? '';
        String subAdminArea = place.subAdministrativeArea ?? '';
        String adminArea = place.administrativeArea ?? '';

        List<String> parts = [];

        if (subLocality.isNotEmpty) {
          parts.add(subLocality);
        }

        if (locality.isNotEmpty) {
          parts.add(locality);
        } else if (subAdminArea.isNotEmpty) {
          parts.add(subAdminArea);
        } else if (adminArea.isNotEmpty) {
          parts.add(adminArea);
        }

        if (parts.isNotEmpty) {
          return parts.join(', ');
        }
      }

      return 'GPS (${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)})';
    } catch (e) {
      debugPrint('[Location] Geocoding error: $e');
      return 'GPS (${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)})';
    }
  }

  Future<void> _fallbackToJakarta() async {
    debugPrint('[Location] Falling back to Jakarta...');
    try {
      _prayerTime = await _prayerService.getPrayerTimesByCity(
        city: 'Jakarta',
        country: 'Indonesia',
      );
      _locationName = 'Jakarta, Indonesia (default)';
      _latitude = -6.2088;
      _longitude = 106.8456;
      _error = null;
      await _saveToCache();
    } catch (e) {
      _error = e.toString();
      debugPrint('[Location] Fallback error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Force refresh location and prayer times
  Future<void> refreshLocation() async {
    await autoDetectLocation(forceRefresh: true);
  }
}
