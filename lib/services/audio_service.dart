import 'package:just_audio/just_audio.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  AudioPlayer get audioPlayer => _audioPlayer;

  /// Get audio URL for specific ayah with custom reciter
  String getAyahAudioUrl(int surahNumber, int ayahNumber, String reciterBaseUrl) {
    // Format: https://everyayah.com/data/Alafasy_64kbps/001001.mp3
    // Surah and ayah numbers are padded to 3 digits
    final surahPadded = surahNumber.toString().padLeft(3, '0');
    final ayahPadded = ayahNumber.toString().padLeft(3, '0');
    return '$reciterBaseUrl/$surahPadded$ayahPadded.mp3';
  }

  /// Play audio for specific ayah with custom reciter
  Future<void> playAyah(int surahNumber, int ayahNumber, String reciterBaseUrl) async {
    try {
      final url = getAyahAudioUrl(surahNumber, ayahNumber, reciterBaseUrl);
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    } catch (e) {
      throw Exception('Gagal memutar audio: $e');
    }
  }

  /// Pause audio
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  /// Resume audio
  Future<void> resume() async {
    await _audioPlayer.play();
  }

  /// Stop audio
  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  /// Check if currently playing
  bool get isPlaying => _audioPlayer.playing;

  /// Get current playing state stream
  Stream<bool> get playingStream => _audioPlayer.playingStream;

  /// Dispose audio player
  void dispose() {
    _audioPlayer.dispose();
  }
}
