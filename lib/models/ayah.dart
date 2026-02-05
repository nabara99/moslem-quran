class Ayah {
  final int number;
  final int numberInSurah;
  final String text;
  final String? translation;
  final int? juz;
  final int? page;

  Ayah({
    required this.number,
    required this.numberInSurah,
    required this.text,
    this.translation,
    this.juz,
    this.page,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    // Clean Arabic text - remove ayah number markers only (keep waqaf signs)
    String cleanText(String text) {
      // First pass: remove common markers
      String cleaned = text
          .replaceAll('●', '')
          .replaceAll('○', '')
          .replaceAll('◯', '')
          .replaceAll('⚫', '')
          .replaceAll('⚪', '')
          .replaceAll('۝', '')
          .replaceAll('۞', '')
          .replaceAll('۩', '');

      // Second pass: use regex to remove ornamental marks and ayah delimiters
      // Remove Unicode range for Arabic presentation forms and special marks
      cleaned = cleaned
          .replaceAll(RegExp(r'[\uFD3E\uFD3F]'), '') // Ornate parentheses
          .replaceAll(RegExp(r'[\u06DD-\u06E8]'), '') // Arabic end marks and small signs
          .replaceAll(RegExp(r'[\u0600-\u0603]'), '') // Arabic number/sign marks
          .replaceAll(RegExp(r'[\u06EA-\u06ED]'), ''); // Arabic empty marks

      return cleaned.trim();
    }

    return Ayah(
      number: json['number'] ?? 0,
      numberInSurah: json['numberInSurah'] ?? 0,
      text: cleanText(json['text'] ?? ''),
      translation: json['translation'],
      juz: json['juz'],
      page: json['page'],
    );
  }
}

class SurahDetail {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final String revelationType;
  final List<Ayah> ayahs;
  final List<Ayah>? translations;

  SurahDetail({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.revelationType,
    required this.ayahs,
    this.translations,
  });

  factory SurahDetail.fromJson(Map<String, dynamic> json, {List<Ayah>? translations}) {
    final surahNumber = json['number'] ?? 0;
    List<Ayah> ayahsList = (json['ayahs'] as List?)?.map((a) => Ayah.fromJson(a)).toList() ?? [];

    // Remove Bismillah from first ayah text (except Al-Fatihah and At-Taubah)
    // Skip for Surah 1 (Al-Fatihah) and Surah 9 (At-Taubah)
    if (surahNumber != 1 && surahNumber != 9 && ayahsList.isNotEmpty) {
      final firstAyah = ayahsList[0];
      String cleanedText = firstAyah.text;

      // Remove Bismillah - try multiple patterns
      // Pattern from API: بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ

      // Try exact match first
      if (cleanedText.contains('بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ')) {
        cleanedText = cleanedText.replaceFirst('بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ', '');
      }
      // Try with flexible whitespace
      else if (cleanedText.contains('بِسْمِ') && cleanedText.contains('ٱللَّهِ')) {
        cleanedText = cleanedText.replaceFirst(
          RegExp(r'بِسْمِ\s*ٱللَّهِ\s*ٱلرَّحْمَٰنِ\s*ٱلرَّحِيمِ'),
          ''
        );
      }
      // Fallback: try removing first 4 words if they start with بسم
      else if (cleanedText.startsWith('بِسْمِ') || cleanedText.startsWith('بسم')) {
        final words = cleanedText.split(' ');
        if (words.length > 4) {
          cleanedText = words.skip(4).join(' ');
        }
      }

      // Clean up any leading/trailing whitespace
      cleanedText = cleanedText.trim();

      // If text was modified and is not empty, update first ayah
      if (cleanedText.isNotEmpty && cleanedText != firstAyah.text) {
        ayahsList[0] = Ayah(
          number: firstAyah.number,
          numberInSurah: firstAyah.numberInSurah,
          text: cleanedText,
          translation: firstAyah.translation,
          juz: firstAyah.juz,
          page: firstAyah.page,
        );
      }
      // If text becomes empty (was only Bismillah), remove the ayah entirely
      else if (cleanedText.isEmpty) {
        ayahsList = ayahsList.skip(1).toList();
      }
    }

    return SurahDetail(
      number: surahNumber,
      name: json['name'] ?? '',
      englishName: json['englishName'] ?? '',
      englishNameTranslation: json['englishNameTranslation'] ?? '',
      revelationType: json['revelationType'] ?? '',
      ayahs: ayahsList,
      translations: translations,
    );
  }
}
