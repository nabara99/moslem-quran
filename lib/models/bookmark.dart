class Bookmark {
  final int surahNumber;
  final int ayahNumber;
  final String surahName;
  final String ayahText;
  final DateTime createdAt;

  Bookmark({
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahName,
    required this.ayahText,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'surahNumber': surahNumber,
      'ayahNumber': ayahNumber,
      'surahName': surahName,
      'ayahText': ayahText,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      surahNumber: json['surahNumber'] ?? 0,
      ayahNumber: json['ayahNumber'] ?? 0,
      surahName: json['surahName'] ?? '',
      ayahText: json['ayahText'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  String get bookmarkKey => '${surahNumber}_$ayahNumber';
}
