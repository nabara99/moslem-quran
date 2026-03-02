import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'dart:math' as math;
import '../constants/app_colors.dart';

class QiblaCompassWidget extends StatelessWidget {
  final QiblahDirection qiblahDirection;

  const QiblaCompassWidget({super.key, required this.qiblahDirection});

  @override
  Widget build(BuildContext context) {
    final compassAngle = -qiblahDirection.direction * (math.pi / 180);
    final needleAngle = qiblahDirection.offset * (math.pi / 180);

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _QiblahInfoChip(qiblah: qiblahDirection.qiblah),
              const SizedBox(height: 40),
              _CompassDial(
                compassAngle: compassAngle,
                needleAngle: needleAngle,
              ),
              const SizedBox(height: 40),
              _DirectionInfoCard(
                direction: qiblahDirection.direction,
                qiblah: qiblahDirection.qiblah,
              ),
              const SizedBox(height: 20),
              Text(
                'Putar perangkat hingga jarum hijau menunjuk ke Ka\'bah',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QiblahInfoChip extends StatelessWidget {
  final double qiblah;

  const _QiblahInfoChip({required this.qiblah});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.explore, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            'Qiblat: ${qiblah.toStringAsFixed(1)}° dari Utara',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompassDial extends StatelessWidget {
  final double compassAngle;
  final double needleAngle;

  const _CompassDial({required this.compassAngle, required this.needleAngle});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: compassAngle,
            child: CustomPaint(
              size: const Size(280, 280),
              painter: _CompassRingPainter(),
            ),
          ),
          Transform.rotate(
            angle: needleAngle,
            child: _QiblaNeedle(),
          ),
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryBlue, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QiblaNeedle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 220,
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.mosque, color: Colors.white, size: 20),
          ),
          Expanded(
            child: Center(
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.green.shade500, Colors.green.shade200],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.red.shade300, Colors.red.shade100],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DirectionInfoCard extends StatelessWidget {
  final double direction;
  final double qiblah;

  const _DirectionInfoCard({required this.direction, required this.qiblah});

  @override
  Widget build(BuildContext context) {
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _InfoItem(
            label: 'Arah Perangkat',
            value: '${direction.toStringAsFixed(0)}°',
            icon: Icons.navigation_outlined,
            iconColor: AppColors.primaryBlue,
          ),
          Container(width: 1, height: 48, color: Colors.grey.shade200),
          _InfoItem(
            label: 'Arah Qiblat',
            value: '${qiblah.toStringAsFixed(0)}°',
            icon: Icons.mosque_outlined,
            iconColor: Colors.green.shade600,
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _InfoItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _CompassRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFFEFF6FF)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.primaryBlue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    for (int i = 0; i < 360; i += 5) {
      final angle = i * math.pi / 180;
      final isMajor = i % 90 == 0;
      final isMedium = i % 45 == 0;
      final isMinor = i % 15 == 0;
      final tickLength = isMajor ? 18.0 : isMedium ? 12.0 : isMinor ? 8.0 : 5.0;

      canvas.drawLine(
        Offset(center.dx + radius * math.sin(angle), center.dy - radius * math.cos(angle)),
        Offset(
          center.dx + (radius - tickLength) * math.sin(angle),
          center.dy - (radius - tickLength) * math.cos(angle),
        ),
        Paint()
          ..color = isMajor
              ? AppColors.primaryBlue
              : AppColors.textSecondary.withValues(alpha: 0.4)
          ..strokeWidth = isMajor ? 2.5 : 1.0
          ..style = PaintingStyle.stroke,
      );
    }

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final cardinals = {'U': 0.0, 'T': 90.0, 'S': 180.0, 'B': 270.0};

    for (final entry in cardinals.entries) {
      final angle = entry.value * math.pi / 180;
      final pos = Offset(
        center.dx + (radius - 32) * math.sin(angle),
        center.dy - (radius - 32) * math.cos(angle),
      );
      textPainter.text = TextSpan(
        text: entry.key,
        style: TextStyle(
          color: entry.key == 'U' ? Colors.red.shade600 : AppColors.primaryBlue,
          fontSize: entry.key == 'U' ? 18 : 14,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        pos - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(_CompassRingPainter oldDelegate) => false;
}
