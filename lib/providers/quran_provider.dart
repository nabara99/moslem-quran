import 'package:flutter/material.dart';
import '../models/surah.dart';
import '../models/ayah.dart';
import '../services/quran_service.dart';

class QuranProvider with ChangeNotifier {
  final QuranService _quranService = QuranService();

  List<Surah> _surahs = [];
  SurahDetail? _currentSurah;
  bool _isLoading = false;
  String? _error;

  List<Surah> get surahs => _surahs;
  SurahDetail? get currentSurah => _currentSurah;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSurahs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _surahs = await _quranService.getAllSurahs();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadSurahDetail(int surahNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentSurah = await _quranService.getSurahDetail(surahNumber);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearCurrentSurah() {
    _currentSurah = null;
    notifyListeners();
  }
}
