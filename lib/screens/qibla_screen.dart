import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/app_colors.dart';
import '../widgets/qibla_compass_widget.dart';
import '../widgets/qibla_calibration_sheet.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  bool _locationGranted = false;
  bool _compassSupported = true;
  bool _checking = true;
  bool _calibrationShown = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() => _checking = true);

    final bool? deviceSupport = await FlutterQiblah.androidDeviceSensorSupport();
    if (deviceSupport == false) {
      if (mounted) {
        setState(() {
          _compassSupported = false;
          _checking = false;
        });
      }
      return;
    }

    final status = await Permission.location.status;
    final bool granted = status.isGranted
        ? true
        : (await Permission.location.request()).isGranted;

    if (mounted) {
      setState(() {
        _locationGranted = granted;
        _checking = false;
      });

      if (granted && !_calibrationShown) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showCalibrationSheet();
        });
      }
    }
  }

  void _showCalibrationSheet() {
    if (!mounted) return;
    _calibrationShown = true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => QiblaCalibrationSheet(
        onDismiss: () => Navigator.pop(context),
      ),
    );
  }

  @override
  void dispose() {
    FlutterQiblah().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Kompas Qiblat'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        actions: [
          if (_locationGranted && !_checking)
            IconButton(
              icon: const Icon(Icons.tune),
              tooltip: 'Kalibrasi kompas',
              onPressed: _showCalibrationSheet,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_checking) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryBlue),
      );
    }

    if (!_compassSupported) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sensors_off, size: 72, color: AppColors.textSecondary),
              SizedBox(height: 16),
              Text(
                'Kompas tidak tersedia di perangkat ini',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (!_locationGranted) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_off,
                size: 72,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              const Text(
                'Izin lokasi diperlukan untuk menentukan arah Qiblat',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _init,
                icon: const Icon(Icons.location_on),
                label: const Text('Berikan Izin Lokasi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primaryBlue),
                SizedBox(height: 16),
                Text(
                  'Mendeteksi arah...',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return QiblaCompassWidget(qiblahDirection: snapshot.data!);
      },
    );
  }
}
