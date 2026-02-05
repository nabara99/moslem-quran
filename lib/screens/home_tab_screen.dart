import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/prayer_provider.dart';
import '../providers/quran_provider.dart';
import '../providers/bookmark_provider.dart';
import '../providers/audio_provider.dart';
import '../providers/engagement_provider.dart';
import '../providers/notification_settings_provider.dart';
import '../models/reciter.dart';
import '../models/surah.dart';
import '../widgets/prayer_header_widget.dart';
import 'surah_list_screen.dart';
import 'bookmark_list_screen.dart';
import 'reciter_selection_screen.dart';
import 'surah_detail_screen.dart';

class HomeTabScreen extends StatefulWidget {
  const HomeTabScreen({super.key});

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      // Auto-detect location for prayer times (GPS -> fallback Jakarta)
      await context.read<PrayerProvider>().autoDetectLocation();

      if (!mounted) return;
      context.read<QuranProvider>().loadSurahs();

      // Update notification provider with new prayer times
      final prayerProvider = context.read<PrayerProvider>();
      if (prayerProvider.prayerTime != null && mounted) {
        context.read<NotificationSettingsProvider>()
            .updatePrayerTimes(prayerProvider.prayerTime);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Consumer3<PrayerProvider, QuranProvider, BookmarkProvider>(
        builder: (context, prayerProvider, quranProvider, bookmarkProvider, child) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: PrayerHeaderWidget(
                  prayerTime: prayerProvider.prayerTime,
                  location: prayerProvider.locationName,
                  isLoading: prayerProvider.isLoading,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _QuranEngagementCard(),
                      const SizedBox(height: 20),
                      _SectionHeader(
                        title: 'Reciters',
                        onSeeAll: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ReciterSelectionScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _RecitersRow(),
                      const SizedBox(height: 20),
                      _QuickAccessCard(
                        title: 'Baca Al-Quran',
                        subtitle:
                            'Baca dan pelajari Al-Quran dengan terjemahan',
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
                      const SizedBox(height: 12),
                      _QuickAccessCard(
                        title: 'Bookmark',
                        subtitle: bookmarkProvider.bookmarks.isEmpty
                            ? 'Belum ada bookmark'
                            : '${bookmarkProvider.bookmarks.length} ayat tersimpan',
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
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QuranEngagementCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<EngagementProvider, BookmarkProvider>(
      builder: (context, engagementProvider, bookmarkProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_stories,
                  color: AppColors.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quran Engagement Time',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 14,
                          color: AppColors.primaryBlue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          engagementProvider.formattedWeeklyTime,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Week',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final quranProvider = context.read<QuranProvider>();

                  // If user has bookmarks, continue from last bookmark
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
                  } else {
                    // Otherwise, navigate to surah list
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SurahListScreen(),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('Continue'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: const Text(
            'See all',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _RecitersRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final reciters = Reciter.getAllReciters();

    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
        return SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: reciters.length,
            itemBuilder: (context, index) {
              final reciter = reciters[index];
              final isSelected = audioProvider.selectedReciter.id == reciter.id;

              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 0 : 8,
                  right: index == reciters.length - 1 ? 0 : 8,
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReciterSelectionScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(50),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: isSelected
                            ? AppColors.primaryBlue
                            : AppColors.accentBlue.withValues(alpha: 0.3),
                        child: Text(
                          reciter.name[0],
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        reciter.name.split(' ')[0],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected
                              ? AppColors.primaryBlue
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
