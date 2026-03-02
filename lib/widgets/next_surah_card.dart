import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/quran_fonts.dart';
import '../models/surah.dart';

class NextSurahCard extends StatelessWidget {
  final Surah nextSurah;
  final VoidCallback onTap;

  const NextSurahCard({
    super.key,
    required this.nextSurah,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 8, bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Surah Selanjutnya',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  nextSurah.englishName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  nextSurah.englishNameTranslation,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  nextSurah.name,
                  style: const TextStyle(
                    fontFamily: QuranFonts.uthmanic,
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
