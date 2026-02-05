import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/prayer_provider.dart';

class PrayerTimeScreen extends StatelessWidget {
  const PrayerTimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Sholat'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              context.read<PrayerProvider>().loadPrayerTimesByLocation();
            },
            tooltip: 'Gunakan lokasi saat ini',
          ),
        ],
      ),
      body: Consumer<PrayerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Terjadi kesalahan',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(provider.error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.loadPrayerTimesByCity(
                        'Jakarta',
                        'Indonesia',
                      ),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final prayerTime = provider.prayerTime;
          if (prayerTime == null) {
            return const Center(child: Text('Memuat jadwal sholat...'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _LocationCard(
                  location: provider.locationName,
                  date: prayerTime.date,
                  hijriDate: prayerTime.hijriDate,
                ),
                const SizedBox(height: 16),
                _PrayerTimeCard(
                  name: 'Subuh',
                  time: prayerTime.fajr,
                  icon: Icons.nightlight_round,
                ),
                _PrayerTimeCard(
                  name: 'Syuruq',
                  time: prayerTime.sunrise,
                  icon: Icons.wb_twilight,
                ),
                _PrayerTimeCard(
                  name: 'Dzuhur',
                  time: prayerTime.dhuhr,
                  icon: Icons.wb_sunny,
                ),
                _PrayerTimeCard(
                  name: 'Ashar',
                  time: prayerTime.asr,
                  icon: Icons.wb_sunny_outlined,
                ),
                _PrayerTimeCard(
                  name: 'Maghrib',
                  time: prayerTime.maghrib,
                  icon: Icons.wb_twilight_outlined,
                ),
                _PrayerTimeCard(
                  name: 'Isya',
                  time: prayerTime.isha,
                  icon: Icons.nights_stay,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final String location;
  final String date;
  final String hijriDate;

  const _LocationCard({
    required this.location,
    required this.date,
    required this.hijriDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.location_on,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              location,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(date, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
              hijriDate,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrayerTimeCard extends StatelessWidget {
  final String name;
  final String time;
  final IconData icon;

  const _PrayerTimeCard({
    required this.name,
    required this.time,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Text(
          time,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
