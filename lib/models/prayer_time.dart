import 'dart:convert';

class PrayerTime {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String date;
  final String hijriDate;

  PrayerTime({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.date,
    required this.hijriDate,
  });

  /// Convert to JSON map for caching
  Map<String, dynamic> toJson() {
    return {
      'fajr': fajr,
      'sunrise': sunrise,
      'dhuhr': dhuhr,
      'asr': asr,
      'maghrib': maghrib,
      'isha': isha,
      'date': date,
      'hijriDate': hijriDate,
    };
  }

  /// Convert to JSON string for SharedPreferences
  String toJsonString() => json.encode(toJson());

  /// Create from JSON string (for loading from cache)
  factory PrayerTime.fromJsonString(String jsonString) {
    final map = json.decode(jsonString) as Map<String, dynamic>;
    return PrayerTime.fromCache(map);
  }

  /// Create from cached JSON map
  factory PrayerTime.fromCache(Map<String, dynamic> json) {
    return PrayerTime(
      fajr: json['fajr'] ?? '',
      sunrise: json['sunrise'] ?? '',
      dhuhr: json['dhuhr'] ?? '',
      asr: json['asr'] ?? '',
      maghrib: json['maghrib'] ?? '',
      isha: json['isha'] ?? '',
      date: json['date'] ?? '',
      hijriDate: json['hijriDate'] ?? '',
    );
  }

  factory PrayerTime.fromJson(Map<String, dynamic> json) {
    final timings = json['timings'] ?? {};
    final date = json['date'] ?? {};
    final hijri = date['hijri'] ?? {};

    String cleanTime(String? time) {
      if (time == null) return '';
      return time.split(' ').first;
    }

    return PrayerTime(
      fajr: cleanTime(timings['Fajr']),
      sunrise: cleanTime(timings['Sunrise']),
      dhuhr: cleanTime(timings['Dhuhr']),
      asr: cleanTime(timings['Asr']),
      maghrib: cleanTime(timings['Maghrib']),
      isha: cleanTime(timings['Isha']),
      date: date['readable'] ?? '',
      hijriDate: '${hijri['day'] ?? ''} ${hijri['month']?['en'] ?? ''} ${hijri['year'] ?? ''}',
    );
  }
}
