import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/prayer_provider.dart';
import '../providers/notification_settings_provider.dart';
import '../widgets/prayer_header_widget.dart';

class PrayerTabScreen extends StatefulWidget {
  const PrayerTabScreen({super.key});

  @override
  State<PrayerTabScreen> createState() => _PrayerTabScreenState();
}

class _PrayerTabScreenState extends State<PrayerTabScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<PrayerProvider>();
      if (provider.prayerTime == null) {
        // Auto-detect location (GPS -> fallback Jakarta)
        await provider.autoDetectLocation();

        // Update notifications with new prayer times
        if (mounted && provider.prayerTime != null) {
          context.read<NotificationSettingsProvider>()
              .updatePrayerTimes(provider.prayerTime);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Consumer<PrayerProvider>(
        builder: (context, provider, child) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: PrayerHeaderWidget(
                  prayerTime: provider.prayerTime,
                  location: provider.locationName,
                  isLoading: provider.isLoading,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Jadwal Sholat Hari Ini',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            color: AppColors.primaryBlue,
                            tooltip: 'Refresh lokasi',
                            onPressed: () async {
                              // Force refresh to get new location
                              await provider.refreshLocation();
                              if (context.mounted && provider.prayerTime != null) {
                                context.read<NotificationSettingsProvider>()
                                    .updatePrayerTimes(provider.prayerTime);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (provider.isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (provider.error != null)
                        _ErrorCard(
                          message: provider.error!,
                          onRetry: () => provider.loadPrayerTimesByCity(
                            'Jakarta',
                            'Indonesia',
                          ),
                        )
                      else if (provider.prayerTime != null) ...[
                        _PrayerDetailCard(
                          name: 'Subuh',
                          time: provider.prayerTime!.fajr,
                          icon: Icons.nightlight_round,
                        ),
                        _PrayerDetailCard(
                          name: 'Syuruq',
                          time: provider.prayerTime!.sunrise,
                          icon: Icons.wb_twilight,
                        ),
                        _PrayerDetailCard(
                          name: 'Dzuhur',
                          time: provider.prayerTime!.dhuhr,
                          icon: Icons.wb_sunny,
                        ),
                        _PrayerDetailCard(
                          name: 'Ashar',
                          time: provider.prayerTime!.asr,
                          icon: Icons.wb_sunny_outlined,
                        ),
                        _PrayerDetailCard(
                          name: 'Maghrib',
                          time: provider.prayerTime!.maghrib,
                          icon: Icons.wb_twilight_outlined,
                        ),
                        _PrayerDetailCard(
                          name: 'Isya',
                          time: provider.prayerTime!.isha,
                          icon: Icons.nights_stay,
                        ),
                      ],
                      const SizedBox(height: 24),
                      const Text(
                        'Pilih Kota',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _CitySelector(
                        onCitySelected: (city) {
                          provider.loadPrayerTimesByCity(city, 'Indonesia');
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

class _PrayerDetailCard extends StatelessWidget {
  final String name;
  final String time;
  final IconData icon;

  const _PrayerDetailCard({
    required this.name,
    required this.time,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
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
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            message,
            style: TextStyle(color: Colors.red.shade700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
        ],
      ),
    );
  }
}

class _CitySelector extends StatelessWidget {
  final Function(String) onCitySelected;

  const _CitySelector({required this.onCitySelected});

  final List<String> cities = const [
    'Jakarta',
    'Bandung',
    'Surabaya',
    'Yogyakarta',
    'Semarang',
    'Medan',
    'Makassar',
    'Palembang',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: cities.map((city) {
        return InkWell(
          onTap: () => onCitySelected(city),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primaryBlue.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              city,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
