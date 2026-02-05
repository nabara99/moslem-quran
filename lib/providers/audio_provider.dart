import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import '../services/audio_service.dart';
import '../models/reciter.dart';

class AudioProvider with ChangeNotifier {
  final AudioService _audioService = AudioService();

  int? _currentSurahNumber;
  int? _currentAyahNumber;
  int? _totalAyahsInSurah;
  bool _isPlaying = false;
  String? _error;
  Reciter _selectedReciter = Reciter.getAllReciters().first;

  int? get currentSurahNumber => _currentSurahNumber;
  int? get currentAyahNumber => _currentAyahNumber;
  bool get isPlaying => _isPlaying;
  String? get error => _error;
  Reciter get selectedReciter => _selectedReciter;

  AudioProvider() {
    // Listen to playing state changes
    _audioService.playingStream.listen((playing) {
      _isPlaying = playing;
      notifyListeners();
    });

    // Listen to player state for completion
    _audioService.audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _onAudioCompleted();
      }
    });

    // Load saved reciter
    _loadSelectedReciter();
  }

  /// Called when audio completes
  void _onAudioCompleted() async {
    if (_currentSurahNumber != null &&
        _currentAyahNumber != null &&
        _totalAyahsInSurah != null) {
      // Check if there's a next ayah
      if (_currentAyahNumber! < _totalAyahsInSurah!) {
        // Play next ayah
        final nextAyah = _currentAyahNumber! + 1;
        _currentAyahNumber = nextAyah;

        try {
          await _audioService.playAyah(
            _currentSurahNumber!,
            nextAyah,
            _selectedReciter.audioUrl,
          );
          _isPlaying = true;
          notifyListeners();
        } catch (e) {
          _error = e.toString();
          _isPlaying = false;
          notifyListeners();
        }
      } else {
        // Reached end of surah
        _isPlaying = false;
        notifyListeners();
      }
    }
  }

  Future<void> _loadSelectedReciter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reciterId = prefs.getString('selected_reciter_id');
      if (reciterId != null) {
        _selectedReciter = Reciter.getReciterById(reciterId);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading reciter: $e');
    }
  }

  Future<void> selectReciter(Reciter reciter) async {
    _selectedReciter = reciter;
    notifyListeners();

    // Save to preferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_reciter_id', reciter.id);
    } catch (e) {
      debugPrint('Error saving reciter: $e');
    }
  }

  /// Check if specific ayah is currently playing
  bool isAyahPlaying(int surahNumber, int ayahNumber) {
    return _isPlaying &&
        _currentSurahNumber == surahNumber &&
        _currentAyahNumber == ayahNumber;
  }

  /// Set total ayahs in current surah
  void setTotalAyahs(int totalAyahs) {
    _totalAyahsInSurah = totalAyahs;
  }

  /// Play or pause ayah
  Future<void> togglePlayPause(int surahNumber, int ayahNumber, {int? totalAyahs}) async {
    try {
      _error = null;

      // Set total ayahs if provided
      if (totalAyahs != null) {
        _totalAyahsInSurah = totalAyahs;
      }

      // If same ayah is playing, toggle pause/resume
      if (_currentSurahNumber == surahNumber &&
          _currentAyahNumber == ayahNumber &&
          _isPlaying) {
        await _audioService.pause();
        _isPlaying = false;
      }
      // If same ayah is paused, resume
      else if (_currentSurahNumber == surahNumber &&
          _currentAyahNumber == ayahNumber &&
          !_isPlaying) {
        await _audioService.resume();
        _isPlaying = true;
      }
      // Play new ayah
      else {
        _currentSurahNumber = surahNumber;
        _currentAyahNumber = ayahNumber;
        await _audioService.playAyah(surahNumber, ayahNumber, _selectedReciter.audioUrl);
        _isPlaying = true;
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isPlaying = false;
      notifyListeners();
    }
  }

  /// Stop audio
  Future<void> stop() async {
    await _audioService.stop();
    _isPlaying = false;
    _currentSurahNumber = null;
    _currentAyahNumber = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
