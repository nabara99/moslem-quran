import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../providers/quran_provider.dart';
import '../providers/bookmark_provider.dart';
import '../providers/audio_provider.dart';
import '../providers/engagement_provider.dart';
import '../models/surah.dart';
import '../constants/app_colors.dart';
import '../constants/quran_fonts.dart';

class SurahDetailScreen extends StatefulWidget {
  final Surah surah;
  final int? scrollToAyah;

  const SurahDetailScreen({super.key, required this.surah, this.scrollToAyah});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();
  int? _lastScrolledAyah;

  @override
  void initState() {
    super.initState();

    // Start engagement tracking
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<EngagementProvider>().startSession();
      await context.read<QuranProvider>().loadSurahDetail(widget.surah.number);

      // Scroll to bookmark after data is loaded
      if (widget.scrollToAyah != null && mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _scrollToPlayingAyah(widget.scrollToAyah!);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    // Stop engagement tracking when leaving the screen
    context.read<EngagementProvider>().stopSession();
    super.dispose();
  }

  void _scrollToPlayingAyah(int ayahNumber) {
    // Index in list: 0 = header, 1 = ayah 1, 2 = ayah 2, etc.
    // So to scroll to ayah N, we scroll to index N (because header is at index 0)
    final targetIndex = ayahNumber; // ayahNumber because index 0 is header, index 1 is ayah 1, etc.

    if (_itemScrollController.isAttached) {
      _itemScrollController.scrollTo(
        index: targetIndex,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
        alignment: 0.1, // Position item 10% from top of viewport
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(widget.surah.englishName),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Consumer2<QuranProvider, AudioProvider>(
        builder: (context, provider, audioProvider, child) {
          // Auto-scroll when ayah changes during audio playback
          if (audioProvider.currentSurahNumber == widget.surah.number &&
              audioProvider.currentAyahNumber != null &&
              audioProvider.currentAyahNumber != _lastScrolledAyah) {
            _lastScrolledAyah = audioProvider.currentAyahNumber;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToPlayingAyah(audioProvider.currentAyahNumber!);
            });
          }

          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Terjadi kesalahan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          provider.loadSurahDetail(widget.surah.number),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final surahDetail = provider.currentSurah;
          if (surahDetail == null) {
            return const Center(
              child: Text(
                'Data tidak ditemukan',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          return ScrollablePositionedList.builder(
            itemScrollController: _itemScrollController,
            itemPositionsListener: _itemPositionsListener,
            padding: const EdgeInsets.all(16),
            itemCount: surahDetail.ayahs.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _SurahHeader(surah: widget.surah);
              }

              final ayah = surahDetail.ayahs[index - 1];
              final translation =
                  surahDetail.translations != null &&
                      index - 1 < surahDetail.translations!.length
                  ? surahDetail.translations![index - 1]
                  : null;

              return _AyahCard(
                key: ValueKey('ayah_${widget.surah.number}_${ayah.numberInSurah}'),
                surahNumber: widget.surah.number,
                surahName: widget.surah.name,
                ayahNumber: ayah.numberInSurah,
                arabicText: ayah.text,
                translation: translation?.text,
                totalAyahs: widget.surah.numberOfAyahs,
              );
            },
          );
        },
      ),
    );
  }
}

class _SurahHeader extends StatelessWidget {
  final Surah surah;

  const _SurahHeader({required this.surah});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              surah.name,
              style: const TextStyle(
                fontFamily: QuranFonts.uthmanic,
                fontSize: 36,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              surah.englishNameTranslation,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${surah.revelationType} • ${surah.numberOfAyahs} Ayat',
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AyahCard extends StatelessWidget {
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final String arabicText;
  final String? translation;
  final int totalAyahs;

  const _AyahCard({
    super.key,
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.arabicText,
    this.translation,
    required this.totalAyahs,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<BookmarkProvider, AudioProvider>(
      builder: (context, bookmarkProvider, audioProvider, child) {
        final isBookmarked = bookmarkProvider.isBookmarked(
          surahNumber,
          ayahNumber,
        );
        final isPlaying = audioProvider.isAyahPlaying(surahNumber, ayahNumber);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$ayahNumber',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isPlaying
                                ? Icons.pause_circle
                                : Icons.play_circle_outline,
                          ),
                          color: AppColors.primaryBlue,
                          iconSize: 28,
                          onPressed: () async {
                            await audioProvider.togglePlayPause(
                              surahNumber,
                              ayahNumber,
                              totalAyahs: totalAyahs,
                            );

                            if (audioProvider.error != null &&
                                context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Gagal memutar audio'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                          ),
                          color: isBookmarked
                              ? AppColors.primaryBlue
                              : AppColors.textSecondary,
                          onPressed: () async {
                            final result = await bookmarkProvider
                                .toggleBookmark(
                                  surahNumber: surahNumber,
                                  ayahNumber: ayahNumber,
                                  surahName: surahName,
                                  ayahText: arabicText,
                                );

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result['message']),
                                  duration: Duration(
                                    seconds: result['replacedOldest'] == true
                                        ? 3
                                        : 2,
                                  ),
                                  backgroundColor: result['success']
                                      ? AppColors.primaryBlue
                                      : Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  arabicText,
                  style: const TextStyle(
                    fontFamily: QuranFonts.uthmanic,
                    fontSize: 26,
                    height: 2,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
                if (translation != null) ...[
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.shade200),
                  const SizedBox(height: 12),
                  Text(
                    translation!,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.7,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
