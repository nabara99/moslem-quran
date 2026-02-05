import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/surah.dart';
import '../models/ayah.dart';

class QuranService {
  static const String _baseUrl = 'https://api.alquran.cloud/v1';

  Future<List<Surah>> getAllSurahs() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/surah'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> surahList = data['data'];
        return surahList.map((s) => Surah.fromJson(s)).toList();
      } else {
        throw Exception('Gagal memuat daftar surah');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<SurahDetail> getSurahDetail(int surahNumber) async {
    try {
      final responses = await Future.wait([
        // Using quran-uthmani from King Fahd Complex (Mushaf Madinah)
        http.get(Uri.parse('$_baseUrl/surah/$surahNumber/quran-uthmani')),
        http.get(Uri.parse('$_baseUrl/surah/$surahNumber/id.indonesian')),
      ]);

      if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
        final arabicData = json.decode(responses[0].body)['data'];
        final translationData = json.decode(responses[1].body)['data'];

        final List<Ayah> translations = (translationData['ayahs'] as List)
            .map((a) => Ayah.fromJson(a))
            .toList();

        return SurahDetail.fromJson(arabicData, translations: translations);
      } else {
        throw Exception('Gagal memuat detail surah');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<String> getAudioUrl(int surahNumber) async {
    return 'https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/$surahNumber.mp3';
  }
}
