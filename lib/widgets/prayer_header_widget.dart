import 'package:flutter/material.dart';
import 'dart:async';
import '../constants/app_colors.dart';
import '../models/prayer_time.dart';

class PrayerHeaderWidget extends StatefulWidget {
  final PrayerTime? prayerTime;
  final String location;
  final bool isLoading;

  const PrayerHeaderWidget({
    super.key,
    this.prayerTime,
    required this.location,
    this.isLoading = false,
  });

  @override
  State<PrayerHeaderWidget> createState() => _PrayerHeaderWidgetState();
}

class _PrayerHeaderWidgetState extends State<PrayerHeaderWidget> {
  late Timer _timer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  String _getNextPrayer() {
    if (widget.prayerTime == null) return '';
    final now = _currentTime;
    final prayers = [
      ('Subuh', widget.prayerTime!.fajr),
      ('Dzuhur', widget.prayerTime!.dhuhr),
      ('Ashar', widget.prayerTime!.asr),
      ('Maghrib', widget.prayerTime!.maghrib),
      ('Isya', widget.prayerTime!.isha),
    ];

    for (var prayer in prayers) {
      final parts = prayer.$2.split(':');
      if (parts.length == 2) {
        final prayerTime = DateTime(
          now.year,
          now.month,
          now.day,
          int.tryParse(parts[0]) ?? 0,
          int.tryParse(parts[1]) ?? 0,
        );
        if (prayerTime.isAfter(now)) {
          final diff = prayerTime.difference(now);
          final hours = diff.inHours;
          final minutes = diff.inMinutes % 60;
          final seconds = diff.inSeconds % 60;
          return '${prayer.$1} dalam ${hours}j ${minutes}m ${seconds}d';
        }
      }
    }
    return 'Subuh besok';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatTime(_currentTime),
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppColors.accentBlue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getNextPrayer(),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.accentBlue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          widget.prayerTime?.hijriDate ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: AppColors.textLight,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  widget.location,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textLight,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (widget.prayerTime != null) _buildPrayerTimesRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerTimesRow() {
    final prayers = [
      ('Subuh', widget.prayerTime!.fajr, Icons.nightlight_round),
      ('Syuruq', widget.prayerTime!.sunrise, Icons.wb_twilight),
      ('Dzuhur', widget.prayerTime!.dhuhr, Icons.wb_sunny),
      ('Ashar', widget.prayerTime!.asr, Icons.wb_sunny_outlined),
      ('Maghrib', widget.prayerTime!.maghrib, Icons.wb_twilight_outlined),
      ('Isya', widget.prayerTime!.isha, Icons.nightlight_round_outlined),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: prayers.map((prayer) {
        final isActive = _isCurrentPrayer(prayer.$1);
        return _PrayerTimeItem(
          name: prayer.$1,
          time: prayer.$2,
          icon: prayer.$3,
          isActive: isActive,
        );
      }).toList(),
    );
  }

  bool _isCurrentPrayer(String prayerName) {
    if (widget.prayerTime == null) return false;
    final now = _currentTime;
    final prayers = [
      ('Subuh', widget.prayerTime!.fajr),
      ('Syuruq', widget.prayerTime!.sunrise),
      ('Dzuhur', widget.prayerTime!.dhuhr),
      ('Ashar', widget.prayerTime!.asr),
      ('Maghrib', widget.prayerTime!.maghrib),
      ('Isya', widget.prayerTime!.isha),
    ];

    for (int i = 0; i < prayers.length - 1; i++) {
      final currentParts = prayers[i].$2.split(':');
      final nextParts = prayers[i + 1].$2.split(':');

      if (currentParts.length == 2 && nextParts.length == 2) {
        final currentTime = DateTime(
          now.year,
          now.month,
          now.day,
          int.tryParse(currentParts[0]) ?? 0,
          int.tryParse(currentParts[1]) ?? 0,
        );
        final nextTime = DateTime(
          now.year,
          now.month,
          now.day,
          int.tryParse(nextParts[0]) ?? 0,
          int.tryParse(nextParts[1]) ?? 0,
        );

        if (now.isAfter(currentTime) && now.isBefore(nextTime)) {
          return prayers[i].$1 == prayerName;
        }
      }
    }
    return false;
  }
}

class _PrayerTimeItem extends StatelessWidget {
  final String name;
  final String time;
  final IconData icon;
  final bool isActive;

  const _PrayerTimeItem({
    required this.name,
    required this.time,
    required this.icon,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: isActive ? AppColors.primaryBlue : AppColors.accentBlue,
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isActive ? AppColors.primaryBlue : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isActive ? AppColors.primaryBlue : AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
