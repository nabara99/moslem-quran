class Reciter {
  final String id;
  final String name;
  final String arabicName;
  final String? description;
  final String audioUrl;

  Reciter({
    required this.id,
    required this.name,
    required this.arabicName,
    this.description,
    required this.audioUrl,
  });

  static List<Reciter> getAllReciters() {
    return [
      Reciter(
        id: 'alafasy',
        name: 'Mishary Rashid Alafasy',
        arabicName: 'مشاري بن راشد العفاسي',
        description: 'Imam Masjidil Haram, Kuwait',
        audioUrl: 'https://everyayah.com/data/Alafasy_64kbps',
      ),
      Reciter(
        id: 'abdulbasit',
        name: 'Abdul Basit Abd As-Samad',
        arabicName: 'عبد الباسط عبد الصمد',
        description: 'Mesir, Mujawwad',
        audioUrl: 'https://everyayah.com/data/Abdul_Basit_Mujawwad_128kbps',
      ),
      Reciter(
        id: 'sudais',
        name: 'Abdurrahman As-Sudais',
        arabicName: 'عبد الرحمن السديس',
        description: 'Imam Masjidil Haram, Makkah',
        audioUrl: 'https://everyayah.com/data/Abdurrahmaan_As-Sudais_64kbps',
      ),
      Reciter(
        id: 'minshawi',
        name: 'Mohamed Siddiq Al-Minshawi',
        arabicName: 'محمد صديق المنشاوي',
        description: 'Mesir, Mujawwad',
        audioUrl: 'https://everyayah.com/data/Minshawy_Mujawwad_192kbps',
      ),
      Reciter(
        id: 'ghamdi',
        name: 'Saad Al-Ghamdi',
        arabicName: 'سعد الغامدي',
        description: 'Arab Saudi',
        audioUrl: 'https://everyayah.com/data/Ghamadi_40kbps',
      ),
      Reciter(
        id: 'husary',
        name: 'Mahmoud Khalil Al-Husary',
        arabicName: 'محمود خليل الحصري',
        description: 'Mesir, Klasik',
        audioUrl: 'https://everyayah.com/data/Husary_64kbps',
      ),
    ];
  }

  static Reciter getReciterById(String id) {
    return getAllReciters().firstWhere(
      (r) => r.id == id,
      orElse: () => getAllReciters().first,
    );
  }
}
