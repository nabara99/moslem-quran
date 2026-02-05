import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/notification_settings_provider.dart';
import '../services/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  Map<String, bool> _permissionStatus = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPermissionStatus();
  }

  Future<void> _loadPermissionStatus() async {
    final status = await _notificationService.getPermissionStatus();
    setState(() {
      _permissionStatus = status;
      _isLoading = false;
    });
  }

  Future<void> _requestPermissions() async {
    setState(() => _isLoading = true);
    await _notificationService.requestPermissions();
    await _loadPermissionStatus();

    // Reschedule notifications after permissions are granted
    if (mounted) {
      final provider = context.read<NotificationSettingsProvider>();
      await provider.forceRescheduleNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    final allPermissionsGranted = _permissionStatus['notification'] == true &&
        _permissionStatus['exactAlarm'] == true;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Pengaturan Notifikasi'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Consumer<NotificationSettingsProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Permission Status Card
              _buildPermissionStatusCard(allPermissionsGranted),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Aktifkan notifikasi untuk mendapatkan pengingat waktu sholat',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primaryBlue.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Notifikasi Waktu Sholat'),
              const SizedBox(height: 12),
              _buildNotificationCard(
                context,
                icon: Icons.nightlight_round,
                title: 'Subuh',
                subtitle: 'Notifikasi saat waktu Subuh tiba',
                value: provider.fajrEnabled,
                onChanged: (value) => provider.toggleFajr(value),
              ),
              _buildNotificationCard(
                context,
                icon: Icons.wb_sunny,
                title: 'Dzuhur',
                subtitle: 'Notifikasi saat waktu Dzuhur tiba',
                value: provider.dhuhrEnabled,
                onChanged: (value) => provider.toggleDhuhr(value),
              ),
              _buildNotificationCard(
                context,
                icon: Icons.wb_sunny_outlined,
                title: 'Ashar',
                subtitle: 'Notifikasi saat waktu Ashar tiba',
                value: provider.asrEnabled,
                onChanged: (value) => provider.toggleAsr(value),
              ),
              _buildNotificationCard(
                context,
                icon: Icons.wb_twilight_outlined,
                title: 'Maghrib',
                subtitle: 'Notifikasi saat waktu Maghrib tiba',
                value: provider.maghribEnabled,
                onChanged: (value) => provider.toggleMaghrib(value),
              ),
              _buildNotificationCard(
                context,
                icon: Icons.nights_stay,
                title: 'Isya',
                subtitle: 'Notifikasi saat waktu Isya tiba',
                value: provider.ishaEnabled,
                onChanged: (value) => provider.toggleIsha(value),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPermissionStatusCard(bool allGranted) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (allGranted) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600, size: 24),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Semua izin sudah aktif. Notifikasi siap digunakan.',
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 24),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Izin belum lengkap',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPermissionItem(
            'Notifikasi',
            _permissionStatus['notification'] ?? false,
          ),
          _buildPermissionItem(
            'Alarm & Pengingat',
            _permissionStatus['exactAlarm'] ?? false,
          ),
          _buildPermissionItem(
            'Hemat Baterai (opsional)',
            _permissionStatus['batteryOptimization'] ?? false,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _requestPermissions,
              icon: const Icon(Icons.settings, size: 18),
              label: const Text('Aktifkan Izin'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _notificationService.openSettings(),
            child: const Text(
              'Buka Pengaturan Aplikasi',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem(String name, bool granted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            granted ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: granted ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 13,
              color: granted ? Colors.black87 : Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryBlue,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12),
        ),
        value: value,
        activeTrackColor: AppColors.primaryBlue,
        onChanged: onChanged,
      ),
    );
  }

}
