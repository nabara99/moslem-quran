import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prayer_time.dart';

class PrayerService {
  static const String _baseUrl = 'https://api.aladhan.com/v1';

  Future<PrayerTime> getPrayerTimesByCoordinates({
    required double latitude,
    required double longitude,
    int method = 20, // 20 = Kementerian Agama Indonesia
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/timings?latitude=$latitude&longitude=$longitude&method=$method',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PrayerTime.fromJson(data['data']);
      } else {
        throw Exception('Gagal memuat jadwal sholat');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<PrayerTime> getPrayerTimesByCity({
    required String city,
    required String country,
    int method = 20,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/timingsByCity?city=$city&country=$country&method=$method',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PrayerTime.fromJson(data['data']);
      } else {
        throw Exception('Gagal memuat jadwal sholat');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
