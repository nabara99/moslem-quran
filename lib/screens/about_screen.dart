import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Logo & Name
          Container(
            padding: const EdgeInsets.all(24),
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
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.menu_book,
                    size: 48,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Moslem Quran',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Versi 1.0.0',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Deskripsi Aplikasi
          _buildSection(
            title: 'Tentang',
            icon: Icons.info_outline,
            child: const Text(
              'Moslem Quran adalah aplikasi Al-Quran digital yang dirancang untuk membantu umat Muslim dalam membaca, mempelajari, dan mengamalkan Al-Quran dalam kehidupan sehari-hari. Aplikasi ini juga dilengkapi dengan fitur jadwal sholat untuk membantu mengingatkan waktu ibadah.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Sumber Al-Quran
          _buildSection(
            title: 'Sumber Al-Quran',
            icon: Icons.auto_stories,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Teks Al-Quran yang digunakan dalam aplikasi ini bersumber dari:',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  'Mushaf',
                  'Quran Uthmani (Rasm Utsmani)',
                ),
                _buildInfoItem(
                  'Standar',
                  'King Fahd Glorious Quran Printing Complex, Madinah Al-Munawwarah',
                ),
                _buildInfoItem(
                  'Terjemahan',
                  'Kementerian Agama Republik Indonesia',
                ),
                _buildInfoItem(
                  'Qari',
                  'Syaikh Mishary Rashid Alafasy',
                ),
                _buildInfoItem(
                  'API',
                  'AlQuran Cloud (alquran.cloud)',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sumber Jadwal Sholat
          _buildSection(
            title: 'Sumber Jadwal Sholat',
            icon: Icons.access_time,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Perhitungan jadwal sholat menggunakan metode resmi yang diakui:',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  'Metode',
                  'Kementerian Agama Republik Indonesia',
                ),
                _buildInfoItem(
                  'Sudut Fajr',
                  '20°',
                ),
                _buildInfoItem(
                  'Sudut Isha',
                  '18°',
                ),
                _buildInfoItem(
                  'API',
                  'Aladhan Prayer Times API (aladhan.com)',
                ),
                const SizedBox(height: 12),
                const Text(
                  'Jadwal sholat dihitung berdasarkan koordinat lokasi Anda untuk memastikan akurasi waktu sholat sesuai dengan posisi matahari di daerah Anda.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Disclaimer
          _buildSection(
            title: 'Catatan Penting',
            icon: Icons.warning_amber_outlined,
            child: const Text(
              'Aplikasi ini dibuat sebagai sarana untuk memudahkan dalam membaca Al-Quran dan mengetahui waktu sholat. Untuk keperluan ibadah yang lebih presisi, disarankan untuk tetap merujuk pada jadwal sholat dari masjid atau lembaga keagamaan setempat.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Credits
          _buildSection(
            title: 'Pengembang',
            icon: Icons.code,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dikembangkan dengan penuh cinta untuk umat Muslim di seluruh dunia.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        color: Colors.red.shade400,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Semoga aplikasi ini menjadi amal jariyah dan bermanfaat bagi seluruh penggunanya.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
