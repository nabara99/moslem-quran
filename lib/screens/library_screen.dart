import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/quran_provider.dart';
import '../providers/bookmark_provider.dart';
import '../models/surah.dart';
import 'surah_list_screen.dart';
import 'bookmark_list_screen.dart';
import 'surah_detail_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('My Qur\'an'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Consumer2<QuranProvider, BookmarkProvider>(
        builder: (context, quranProvider, bookmarkProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _LibrarySection(
                title: 'Al-Qur\'an',
                items: [
                  _LibraryItem(
                    title: 'Daftar Surah',
                    subtitle: '114 Surah',
                    icon: Icons.menu_book,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SurahListScreen(),
                        ),
                      );
                    },
                  ),
                  _LibraryItem(
                    title: 'Bookmark',
                    subtitle: bookmarkProvider.bookmarks.isEmpty
                        ? 'Belum ada bookmark'
                        : '${bookmarkProvider.bookmarks.length} ayat ditandai',
                    icon: Icons.bookmark,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BookmarkListScreen(),
                        ),
                      );
                    },
                  ),
                  _LibraryItem(
                    title: 'Terakhir Dibaca',
                    subtitle: bookmarkProvider.bookmarks.isNotEmpty
                        ? '${bookmarkProvider.bookmarks.last.surahName} - Ayat ${bookmarkProvider.bookmarks.last.ayahNumber}'
                        : 'Belum ada riwayat',
                    icon: Icons.history,
                    onTap: () {
                      if (bookmarkProvider.bookmarks.isNotEmpty) {
                        final lastBookmark = bookmarkProvider.bookmarks.last;

                        // Find surah from loaded surahs
                        final surah = quranProvider.surahs.firstWhere(
                          (s) => s.number == lastBookmark.surahNumber,
                          orElse: () => Surah(
                            number: lastBookmark.surahNumber,
                            name: lastBookmark.surahName,
                            englishName: lastBookmark.surahName,
                            englishNameTranslation: '',
                            numberOfAyahs: 0,
                            revelationType: '',
                          ),
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SurahDetailScreen(
                              surah: surah,
                              scrollToAyah: lastBookmark.ayahNumber,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LibrarySection extends StatelessWidget {
  final String title;
  final List<_LibraryItem> items;

  const _LibrarySection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        item.icon,
                        color: AppColors.primaryBlue,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      item.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                    ),
                    onTap: item.onTap,
                  ),
                  if (index < items.length - 1)
                    Divider(height: 1, indent: 70, color: Colors.grey.shade200),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _LibraryItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  _LibraryItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}
