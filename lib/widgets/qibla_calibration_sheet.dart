import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../constants/app_colors.dart';

class QiblaCalibrationSheet extends StatefulWidget {
  final VoidCallback onDismiss;

  const QiblaCalibrationSheet({super.key, required this.onDismiss});

  @override
  State<QiblaCalibrationSheet> createState() => _QiblaCalibrationSheetState();
}

class _QiblaCalibrationSheetState extends State<QiblaCalibrationSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Kalibrasi Kompas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Lakukan kalibrasi agar arah kompas akurat',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: 160,
            height: 160,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final t = _controller.value * 2 * math.pi;
                final x = 45.0 * math.sin(t);
                final y = 45.0 * math.sin(t) * math.cos(t);
                final tilt = math.sin(t) * 0.4;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(160, 160),
                      painter: _Figure8Painter(progress: _controller.value),
                    ),
                    Transform.translate(
                      offset: Offset(x, y),
                      child: Transform.rotate(
                        angle: tilt,
                        child: const Icon(
                          Icons.smartphone,
                          size: 38,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                _StepItem(
                  number: '1',
                  text: 'Pegang perangkat secara horizontal',
                ),
                SizedBox(height: 10),
                _StepItem(
                  number: '2',
                  text: 'Gerakkan perlahan membentuk pola angka 8',
                ),
                SizedBox(height: 10),
                _StepItem(
                  number: '3',
                  text: 'Ulangi 2–3 kali hingga kompas stabil',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onDismiss,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Mengerti, Mulai Kompas',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String number;
  final String text;

  const _StepItem({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.primaryBlue,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _Figure8Painter extends CustomPainter {
  final double progress;

  const _Figure8Painter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final path = Path();

    for (int i = 0; i <= 360; i++) {
      final t = i * math.pi / 180;
      final x = center.dx + 45 * math.sin(t);
      final y = center.dy + 45 * math.sin(t) * math.cos(t);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Full path (faint)
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.primaryBlue.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // Animated progress highlight
    final highlightPath = Path();
    final highlightCount = (360 * progress).toInt();
    for (int i = 0; i <= highlightCount; i++) {
      final t = i * math.pi / 180;
      final x = center.dx + 45 * math.sin(t);
      final y = center.dy + 45 * math.sin(t) * math.cos(t);
      if (i == 0) {
        highlightPath.moveTo(x, y);
      } else {
        highlightPath.lineTo(x, y);
      }
    }

    canvas.drawPath(
      highlightPath,
      Paint()
        ..color = AppColors.primaryBlue.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_Figure8Painter oldDelegate) =>
      oldDelegate.progress != progress;
}
